require File.expand_path('../lib/charcutio_requirements', __FILE__)

class Charcutio
  DEPLOY_DIR = "/usr/local/charcutio" # TODO fix this
  LOGGER = Logger.new("#{DEPLOY_DIR}/charcutio.log")

  attr_accessor :board, :door, :id, :pins

  def initialize(pins)
    LOGGER.info "Charcut.io starting up..."
    @id = get_id
    @board = Dino::Board.new Dino::TxRx.new
    @pins = pins
    @door = Door.new(self)
  end

  def light
    @light ||= Light.new(self)
  end

  def post_data_point(data_type, value)
    FridgeApiClient.post_data_point data_type, value
  end

  def run
    if @id
      register_remaining_sensors
      SetpointUpdater.supervise_as :setpoint_updater
      MeatPhotographer.supervise_as :meat_photographer, webcam
      Humidistat.supervise_as :humidistat, @board, @pins
      Thermostat.supervise_as :thermostat, @board, @pins
      WeightSensor.supervise_as :weight_sensor
      sleep
    else
      puts "Can't run a fridge without an ID!"
    end
  end

  def sensors
    @sensors ||= {}
  end

  def webcam
    @webcam ||= Webcam.new(light)
  end

  private

    def get_id
      id_file = "#{DEPLOY_DIR}/id"
      File.open(id_file, 'w') { |f| f.puts "1" }
      return 1
      # temp_id = File.readlines(id_file).first if File.exist?(id_file)
      # return temp_id.to_i if temp_id && temp_id.length > 0
      # temp_id = FridgeApiClient.get_id
      # File.open(id_file, 'w') { |f| f.puts temp_id }
    end

    def register_remaining_sensors
      sensors[:humidity] = {actor_key: :humidistat, sensor: Dino::Components::DHT22.new(pin: @pins[:humidity_pin], board: @board)}
      sensors[:temperature] = {actor_key: :thermostat, sensor: Dino::Components::OneWire.new(pin: @pins[:temperature_pin], board: @board)}
      sensors[:weight] = {actor_key: :weight_sensor, sensor: Dino::Components::Sensor.new(pin: pins[:weight_pin], board: board)} if @pins[:weight_pin]
      sensors.each { |key, sensor| sensor[:sensor].when_data_received sensor_callback(sensor) }
    end

    def sensor_callback(sensor)
      Proc.new do |data|
        actor = sensor_current_actor(sensor[:actor_key])
        actor.latest_sensor_data = data if actor
      end
    end

    def sensor_current_actor(key)
      Celluloid::Actor[key]
    end

end


if __FILE__ == $0
  Charcutio.new(light_pins: '9,10,11', humidifier_pin: '3', dehumidifier_pin: '4', humidity_pin: '8', freezer_pin: '2', temperature_pin: '7', weight_pin: 'A4', door_pin:'A2').run
end
