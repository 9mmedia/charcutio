class Thermostat < BaseRegulator
  attr_reader :temperature_sensor

  def latest_sensor_data
    File.readlines('tmp/temperature').first.to_f
  end

  def set_relays
    @freezer = Dino::Components::Led.new(pin: @pins[:freezer_pin], board: @board)
  end

  def set_sensors
    @temperature_sensor = Dino::Components::OneWire.new(pin: @pins[:temperature_pin], board: @board)
    @sensors = {temperature: @temperature_sensor}
  end

  def update_relay_states
    if latest_sensor_data >= goal_state + 10
      @freezer.on
    else
      @freezer.off
    end
  end
end
