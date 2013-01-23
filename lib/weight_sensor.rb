class WeightSensor
  include Celluloid

  def initialize
    every(30) { post_latest_sensor_data }
  end

  def latest_sensor_data=(value)
    @latest_sensor_data = value.to_f
  end

  private

    def post_latest_sensor_data
      FridgeApiClient.post_data_point 'weight', @latest_sensor_data if @latest_sensor_data
    end
end
