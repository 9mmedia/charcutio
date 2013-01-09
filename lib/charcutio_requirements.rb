%w(logger rubygems bundler/setup celluloid dino rest_client).each do |lib|
  require lib
end
require File.expand_path('../fridge_api_client', __FILE__)
require File.expand_path('../setpoint_updater', __FILE__)
require File.expand_path('../sensor_registrar', __FILE__)
require File.expand_path('../regulator_requirements', __FILE__)
require File.expand_path('../photo_requirements', __FILE__)
require File.expand_path('../weight_sensor', __FILE__)
