class WeightSensor
  include Celluloid

  def initialize(fridge, pin)
    @fridge = fridge
    @sensor = Dino::Components::Sensor.new(pin: pin, board: fridge.board)
  end

  def latest_sensor_data=(value)
    @latest_sensor_data = value
  end

  def run
    SensorRegistrar.register_sensor Actor.current, @sensor
    sleep 5
    loop do
      @fridge.post_data_point 'weight', @latest_sensor_data if @latest_sensor_data
      sleep 30
    end
  end
end
