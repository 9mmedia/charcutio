class Humidistat < BaseRegulator
  attr_reader :dehumidifier, :humidifier, :humidity_sensor

  def latest_sensor_data
    File.readlines('tmp/humidity').first.to_f
  end

  def set_relays
    @humidifier = Dino::Components::Led.new(pin: @pins[:humidifier_pin], board: @board)
    @dehumidifier = Dino::Components::Led.new(pin: @pins[:dehumidifier_pin], board: @board)
  end

  def set_sensors
    @humidity_sensor = Dino::Components::Sensor.new(pin: @pins[:humidity_pin], board: @board)
    @sensors = {humidity: @humidity_sensor}
  end

  def update_relay_states
    current_data = latest_sensor_data
    if current_data <= goal_state - 10
      @humidifier.on
      @dehumidifier.off
    elsif current_data >= goal_state + 10
      @humidifier.off
      @dehumidifier.on
    else
      @humidifier.off
      @dehumidifier.off
    end
  end
end
