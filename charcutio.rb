require File.expand_path('../lib/charcutio_requirements', __FILE__)

class Charcutio
  DEPLOY_DIR = "/usr/local/charcutio" # TODO fix this
  LOGGER = Logger.new("#{DEPLOY_DIR}/logfile.log")

  attr_accessor :board, :door, :id, :pins

  def initialize(pins)
    @id = 1  #get_id
    @board = Dino::Board.new Dino::TxRx.new
    @pins = pins
    @door = Door.new(self)
  end

  def client
    @api_client ||= FridgeApiClient.new(self)
  end

  def humidistat
    Humidistat.supervise_as :humidistat, self
    Celluloid::Actor[:humidistat]
  end

  def thermostat
    Thermostat.supervise_as :thermostat, self
    Celluloid::Actor[:thermostat]
  end

  def light
    @light ||= Light.new(self)
  end

  def webcam
    @webcam ||= Webcam.new(light)
  end

  def post_data_point(data_type, value)
    client.post_data_point data_type, value
  end

  def run
    if @id
      run_weight_sensor if pins[:weight_pin]
      regularly_update_set_points
      humidistat.maintain_goal_state
      thermostat.maintain_goal_state
      run_meat_photographer
      sleep
    else
      puts "Can't run a fridge without an ID!"
    end
  end

  private

    def get_id
      return @id if @id
      id_file = "#{DEPLOY_DIR}/id"
      temp_id = File.readlines(id_file).first if File.exist?(id_file)
      return temp_id.to_i if temp_id && temp_id.length > 0
      temp_id = client.get_id
      File.open(id_file, 'w') { |f| f.puts temp_id }
      temp_id
    end

    def run_meat_photographer
      MeatPhotographer.supervise_as :meat_photographer, webcam, client
      Celluloid::Actor[:meat_photographer].run
    end

    def run_weight_sensor
      WeightSensor.supervise_as :weight_sensor, self, pins[:weight_pin]
      Celluloid::Actor[:weight_sensor].run
    end
end


if __FILE__ == $0
  Charcutio.new(light_pins: '11,12,13', humidifier_pin: '3', dehumidifier_pin: '4', humidity_pin: '8', freezer_pin: '2', temperature_pin: '7', weight_pin: 'A4', door_pin:'A2').run
end
