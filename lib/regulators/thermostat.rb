class Thermostat < BaseRegulator
  attr_reader :temperature_sensor

  def set_relays
    @freezer = Dino::Components::Led.new(pin: @pins[:freezer_pin], board: @board)
  end

  def set_sensors
    @temperature_sensor = Dino::Components::OneWire.new(pin: @pins[:temperature_pin], board: @board)
    @sensors = {temperature: @temperature_sensor}
  end
end
