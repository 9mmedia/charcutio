class WeightSensor
  include Celluloid

  def initialize(board, pins)
    @sensor = Dino::Components::Sensor.new(pin: pins[:weight_pin], board: board)
    regularly_post_weight_data
  end

  def latest_sensor_data=(value)
    @latest_sensor_data = value.to_f
  end

  def regularly_post_weight_data
    SensorRegistrar.register_sensor Actor.current, @sensor
    sleep 5
    every(30) { post_latest_sensor_data }
  end

  private

    def post_latest_sensor_data
      FridgeApiClient.post_data_point 'weight', @latest_sensor_data if @latest_sensor_data
    end
end
