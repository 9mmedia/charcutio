require File.expand_path('../sensor_registrar', __FILE__)

class WeightSensor
  include Celluloid

  def initialize(fridge, pin)
    @fridge = fridge
    @sensor = Dino::Components::Sensor.new(pin: pin, board: fridge.board)
  end

  def latest_data=(value)
    @latest_data = value
  end

  def run
    SensorRegistrar.register_sensor Actor.current, @sensor
    loop do
      @fridge.post_data_point 'weight', @latest_data if @latest_data
      sleep 30
    end
  end
end
