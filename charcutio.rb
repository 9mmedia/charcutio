%w(logger rubygems bundler/setup dino rest_client).each do |lib|
  require lib
end
require File.expand_path('../lib/fridge_api_client', __FILE__)
require File.expand_path('../lib/regulators', __FILE__)
require File.expand_path('../lib/webcam', __FILE__)
require File.expand_path('../lib/light', __FILE__)
require File.expand_path('../lib/door', __FILE__)
require File.expand_path('../lib/meat_photographer', __FILE__)

class Charcutio
  DEPLOY_DIR = "/usr/local/charcutio" # TODO fix this
  LOGGER = Logger.new("#{DEPLOY_DIR}/logfile.log")

  attr_accessor :board, :id, :pins

  def initialize(pins)
    @id = get_id
    @board = Dino::Board.new Dino::TxRx.new
    @pins = pins
    @weight_sensor = Dino::Components::Sensor.new(pin: @pins[:weight_pin], board: @board) if @pins[:weight_pin]
    @door = Door.new(self)
  end

  def client
    @api_client ||= FridgeApiClient.new(self)
  end

  def humidistat
    @humidistat ||= Humidistat.new(self)
  end

  def thermostat
    @thermostat ||= Thermostat.new(self)
  end

  def light
    @light ||= Light.new(self)
  end

  def webcam
    @webcam ||= Webcam.new(light)
  end

  def door
    @door
  end

  def post_data_point(data_type, value)
    client.post_data_point data_type, value
  end

  def register_sensor(sensor_name, sensor)
    sensor.when_data_received sensor_callback(sensor_name)
  end

  def regularly_update_set_points
    Thread.new do
      register_weight_sensor
      loop do
        post_data_point 'weight', latest_weight_data if @weight_sensor
        get_set_points
        sleep 30
      end
    end
  end

  def run
    if @id
      regularly_update_set_points
      humidistat.maintain_goal_state
      thermostat.maintain_goal_state
      MeatPhotographer.new(webcam, client).run
      sleep
    else
      puts "Can't run a fridge without an ID!"
    end
  end

  private

    def get_id
      id_file = "#{DEPLOY_DIR}/id"
      return @id if @id
      temp_id = File.readlines(id_file).first if File.exist?(id_file)
      return temp_id.to_i if temp_id && temp_id.length > 0
      temp_id = client.get_id
      File.open(id_file, 'w') { |f| f.puts temp_id }
      temp_id
    end

    def get_set_points
      humidistat.goal_state = 50
      thermostat.goal_state = 13
      # set_points = client.get_set_points
      # humidistat.goal_state = set_points['humidity'].to_f
      # thermostat.goal_state = set_points['temperature'].to_f
    rescue => e
      LOGGER.error "#{Time.current} = #{e}"
    end

    def latest_weight_data
      File.readlines('tmp/weight').first.to_f
    end

    def register_weight_sensor
      register_sensor 'weight', @weight_sensor if @weight_sensor
      sleep 2
    end

    def sensor_callback(sensor_name)
      Proc.new do |data|
        File.open("tmp/#{sensor_name}", 'w') { |f| f.puts data }
      end
    end
end


if __FILE__ == $0
  Charcutio.new(light_pins: '11,12,13', humidifier_pin: '3', dehumidifier_pin: '4', humidity_pin: '8', freezer_pin: '2', temperature_pin: '7', weight_pin: 'A4', door_pin:'A2').run
end
