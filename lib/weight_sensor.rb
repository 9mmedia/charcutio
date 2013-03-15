class WeightSensor
  include Celluloid

  @data = []

  def initialize
    every(30) { post_latest_sensor_data }
  end

  def latest_sensor_data=(value)
    @latest_sensor_data = value.to_f
    @data.push(@latest_sensor_data)
  end

  private

    def post_latest_sensor_data
      @data.sort!
      start = (@data.size * 0.25).to_i
      last = (@data.size * .75).to_i
      trimmed_data = @data[start..last]
      avg = trimmed_data.reduce(:+).to_f / trimmed_data.size
      puts avg
      FridgeApiClient.post_data_point 'weight', @latest_sensor_data if @latest_sensor_data
      @data = []
    end
end
