module FridgeApiClient
  DEPLOY_DIR = "/usr/local/charcutio" # TODO fix this

  def self.get_id
    id = RestClient.post "#{ENV['API_URL']}/boxes", api_key: ENV['API_KEY'], name: 'Charcutio'
    id = id.match(/:(\d+)/)
    id[1] if id
  end

  def self.get_set_points
    response = RestClient.get "#{ENV['API_URL']}/boxes/#{fridge_id}/set_points", api_key: ENV['API_KEY']
    JSON.parse response
  end

  def self.post_data_point(data_type, value)
    RestClient.post "#{ENV['API_URL']}/boxes/#{fridge_id}/report", api_key: ENV['API_KEY'], type: data_type, value: value
  end

  def self.post_meatshot(file_path)
    RestClient.post "#{ENV['API_URL']}/boxes/#{fridge_id}/photo", api_key: ENV['API_KEY'], image_file: File.new(file_path, 'rb')
  end

  def self.fridge_id
    @fridge_id ||= File.readlines("#{DEPLOY_DIR}/id").first if File.exist?("#{DEPLOY_DIR}/id")
  end
end
