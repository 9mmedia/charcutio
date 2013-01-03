class Thermostat < BaseRegulator
  attr_reader :freezer, :temperature_sensor

  def goal_state=(value)
    File.open('tmp/temperature_goal', 'w') { |f| f.puts value }
  end

  def goal_state
    File.readlines('tmp/temperature_goal').first.to_f
  end

  def latest_sensor_data
    File.readlines('tmp/temperature').first.to_f
  end

  def  sensor_name
    'temperature'
  end

  def set_relays
    @freezer = Dino::Components::Led.new(pin: @pins[:freezer_pin], board: @board) if @pins[:freezer_pin]
  end

  def set_sensors
    @temperature_sensor = Dino::Components::OneWire.new(pin: @pins[:temperature_pin], board: @board)
    @sensors = {temperature: @temperature_sensor}
  end

  def update_relay_states
    if latest_sensor_data >= goal_state + 5
      puts "freezer should go on"
      @freezer.on unless @freezer_on || !@freezer
      @freezer_on = true
    else
      puts "freezer should go off"
      @freezer.off if @freezer_on && @freezer
      @freezer_on = false
    end
    @fridge.post_data_point 'freezer', @freezer_on
  end
end
