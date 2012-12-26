class Humidistat < BaseRegulator
  def set_relays
    @humidifier = Dino::Components::Led.new(pin: @pins[:humidifier_pin], board: @board)
    @dehumidifier = Dino::Components::Led.new(pin: @pins[:dehumidifier_pin], board: @board)
  end

  def set_sensors
    @humidity_sensor = Dino::Components::Sensor.new(pin: @pins[:humidity_pin], board: @board)
    @sensors = {humidity: @humidity_sensor}
  end
end
