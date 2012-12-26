%w(rubygems bundler/setup dino base_regulator).each do |lib|
  require lib
end

class Thermostat < BaseRegulator
  def set_relays
    @freezer = Dino::Components::Led.new(pin: @pins[:freezer_pin], board: @board)
  end

  def set_sensors
    @temperature_sensor = Dino::Components::Sensor.new(pin: @pins[:temperature_pin], board: @board)
  end
end
