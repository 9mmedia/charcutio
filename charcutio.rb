require File.expand_path('../lib/charcutio_requirements', __FILE__)

class Charcutio
  DEPLOY_DIR = "/usr/local/charcutio" # TODO fix this
  LOGGER = Logger.new("#{DEPLOY_DIR}/logfile.log")

  attr_accessor :board, :door, :id, :pins

  def initialize(pins)
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
      setup_celluloid_actors
      Celluloid::Actor[:setpoint_updater].regularly_update_set_points
      Celluloid::Actor[:humidistat].maintain_goal_state
      Celluloid::Actor[:thermostat].maintain_goal_state
      Celluloid::Actor[:meat_photographer].take_regularly_scheduled_photos
      Celluloid::Actor[:weight_sensor].regularly_post_weight_data if pins[:weight_pin]
      sleep
    else
      puts "Can't run a fridge without an ID!"
    end
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

    def setup_celluloid_actors
      SetpointUpdater.supervise_as :setpoint_updater
      MeatPhotographer.supervise_as :meat_photographer, webcam
      Humidistat.supervise_as :humidistat, @board, @pins
      Thermostat.supervise_as :thermostat, @board, @pins
      WeightSensor.supervise_as :weight_sensor, @board, @pins if @pins[:weight_pin]
    end
end


if __FILE__ == $0
  Charcutio.new(light_pins: '11,12,13', humidifier_pin: '3', dehumidifier_pin: '4', humidity_pin: '8', freezer_pin: '2', temperature_pin: '7', weight_pin: 'A4', door_pin:'A2').run
end
