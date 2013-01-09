class WeightSensor
  include Celluloid

  def initialize(board, pins)
    @sensor = Dino::Components::Sensor.new(pin: pins[:weight_pin], board: board)
  end

  def latest_sensor_data=(value)
    @latest_sensor_data = value
  end

  def run
    SensorRegistrar.register_sensor Actor.current, @sensor
    sleep 5
    loop do
      FridgeApiClient.post_data_point 'weight', @latest_sensor_data if @latest_sensor_data
      sleep 30
    end
  end
end
