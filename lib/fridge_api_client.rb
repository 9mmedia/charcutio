%w(rubygems bundler/setup dino rest_client).each do |lib|
  require lib
end

class FridgeApiClient
  def initialize(fridge)
    @fridge = fridge
    @base_url = ''
  end
end
