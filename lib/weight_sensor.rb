class WeightSensor
  include Celluloid

  attr_accessor :key

  def initialize
    Charcutio::LOGGER.info "initialized weight sensor: #{key}"
    @data ||= []
    every(10) { post_latest_sensor_data }
  end

  def latest_sensor_data=(value)
    @latest_sensor_data = value.to_f
    @data = @data[1..-1] if @data.size >= 10
    @data.push(@latest_sensor_data)
  end

  private

    def post_latest_sensor_data
      data = @data.sort
      avg = data.reduce(:+).to_f / data.size
      #Charcutio::LOGGER.info "#{@key} - AVG:#{avg} SIZE:#{data.size}"
      FridgeApiClient.post_data_point key, avg if @latest_sensor_data
    end
end