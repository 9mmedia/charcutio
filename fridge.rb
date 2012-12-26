%w(logger rubygems bundler/setup dino rest_client).each do |lib|
  require lib
end
require File.expand_path('../lib/fridge_api_client', __FILE__)
require File.expand_path('../lib/regulators', __FILE__)

class Fridge
  LOGGER = Logger.new('logfile.log')
  attr_accessor :board, :pins

  def initialize(pins)
    @board = Dino::Board.new Dino::TxRx.new
    @pins = pins
    # @weight_sensor = Dino::Components::Sensor.new(pin: @pins[:weight_pin], board: @board)
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

  def regularly_update_set_points
    Thread.new do
      loop do
        get_set_points
        puts "current data: #{File.readlines('temperature').first.to_f}"
        sleep 30
      end
    end
  end

  def run
    regularly_update_set_points
    # humidistat.maintain_goal_state
    # thermostat.maintain_goal_state
    thermostat.on_sensor_data "temperature", thermostat.temperature_sensor
    sleep
  end

  private

    def get_set_points(data=nil)
      thermostat.goal_state = 28
      # humidistat.goal_state, thermostat.goal_state = client.get_set_points(data)
    rescue => e
      LOGGER.error "#{Time.current} = #{e}"
    end
end


if __FILE__ == $0
  Fridge.new(humidifier_pin: '', dehumidifier_pin: '', humidity_pin: '', freezer_pin: '', temperature_pin: '2', weight_pin: '').run
end
