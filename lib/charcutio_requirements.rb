%w(logger rubygems bundler/setup celluloid dino rest_client).each do |lib|
  require lib
end
require File.expand_path('../fridge_api_client', __FILE__)
require File.expand_path('../setpoint_updater', __FILE__)
require File.expand_path('../sensor_registrar', __FILE__)
require File.expand_path('../regulators', __FILE__)
require File.expand_path('../webcam', __FILE__)
require File.expand_path('../light', __FILE__)
require File.expand_path('../door', __FILE__)
require File.expand_path('../meat_photographer', __FILE__)
require File.expand_path('../weight_sensor', __FILE__)
