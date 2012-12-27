class Thermostat < BaseRegulator
  attr_reader :freezer, :temperature_sensor

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
    puts "latest_sensor_data: #{latest_sensor_data}"
    # if latest_sensor_data >= goal_state + 10
    if latest_sensor_data >= 25
      puts "should go on"
      @freezer.on unless @freezer_on
      @freezer_on = true
    else
      puts "should go off"
      @freezer.off if @freezer_on
      @freezer_on = false
    end
  end
end
