%w(rubygems bundler/setup dino rest_client).each do |lib|
  require lib
end

class FridgeApiClient
  API_KEY = ''

  def initialize(fridge)
    @fridge = fridge
    @base_url = 'http://charcut.io'
  end

  def get_id
    RestClient.post "#{@base_url}/boxes", params: {api_key: FridgeApiClient::API_KEY, name: 'Charcutio'}
  end

  def get_set_points
    RestClient.get @base_url #somethingsomething
    [humidity_set_point, temperature_set_point]
  end

  def post_sensor_data(sensor_name, sensor_data)
    RestClient.post @base_url #somethingsomething
  end
end
