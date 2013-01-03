%w(rubygems bundler/setup dino rest_client).each do |lib|
  require lib
end

class FridgeApiClient
  def initialize(fridge)
    @fridge = fridge
  end

  def get_id
    id = RestClient.post "#{ENV['API_URL']}/boxes", api_key: ENV['API_KEY'], name: 'Charcutio'
    id = id.match(/:(\d+)/)
    id[1] if id
  end

  def get_set_points
    response = RestClient.get "#{ENV['API_URL']}/boxes/#{@fridge.id}/set_points", api_key: ENV['API_KEY']
    JSON.parse response
  end

  def post_data_point(data_type, value)
    puts "posting data point (#{data_type}: #{value})"
    RestClient.post "#{ENV['API_URL']}/boxes/#{@fridge.id}/report", api_key: ENV['API_KEY'], type: data_type, value: value
  end

  def post_meatshot(file_path)
    RestClient.post "#{ENV['API_URL']}/boxes/#{@fridge.id}/photo", api_key: ENV['API_KEY'], image_file: File.new(file_path, 'rb')
  end
end
