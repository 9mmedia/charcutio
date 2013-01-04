%w(logger rubygems bundler/setup dino rest_client).each do |lib|
  require lib
end
require File.expand_path('../lib/fridge_api_client', __FILE__)
require File.expand_path('../lib/regulators', __FILE__)
require File.expand_path('../lib/webcam', __FILE__)
require File.expand_path('../lib/light', __FILE__)
require File.expand_path('../lib/meat_photographer', __FILE__)

class Charcutio
  LOGGER = Logger.new('tmp/logfile.log')

  attr_accessor :board, :id, :pins

  def initialize(pins)
    @id = get_id
    @board = Dino::Board.new Dino::TxRx.new
    @pins = pins
    @weight_sensor = Dino::Components::Sensor.new(pin: @pins[:weight_pin], board: @board) if @pins[:weight_pin]
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

  def post_data_point(data_type, value)
    client.post_data_point data_type, value
  end

  def register_sensor(sensor_name, sensor)
    sensor.when_data_received sensor_callback(sensor_name)
  end

  def regularly_update_set_points
    Thread.new do
      loop do
        post_data_point weight, latest_weight_data if @weight_sensor
        get_set_points
        puts "updating set points"
        sleep 30
      end
    end
  end

  def run
    if @id
      register_weight_sensor
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
      return @id if @id
      temp_id = File.readlines('tmp/id').first if File.exist?('tmp/id')
      return temp_id.to_i if temp_id && temp_id.length > 0
      temp_id = client.get_id
      File.open("tmp/id", 'w') { |f| f.puts temp_id }
      temp_id
    end

    def get_set_points
      humidistat.goal_state = 50
      thermostat.goal_state = 15
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
        puts "#{sensor_name}: #{data}"
        File.open("tmp/#{sensor_name}", 'w') { |f| f.puts data }
      end
    end
end


if __FILE__ == $0
  Charcutio.new(light_pins: '11,12,13', humidifier_pin: '3', dehumidifier_pin: '4', humidity_pin: '8', freezer_pin: '2', temperature_pin: '7', weight_pin: 'A4').run
end
