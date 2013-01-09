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
    every 30, post_latest_sensor_data
  end

  private

    def post_latest_sensor_data
      Proc.new do
        FridgeApiClient.post_data_point 'weight', @latest_sensor_data if @latest_sensor_data
      end
    end
end
