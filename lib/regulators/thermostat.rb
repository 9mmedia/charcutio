class Thermostat < BaseRegulator

  def  sensor_name
    'temperature'
  end

  def set_relays
    @freezer = Dino::Components::Led.new(pin: @pins[:freezer_pin], board: @board) if @pins[:freezer_pin]
  end

  def set_sensors
    temperature_sensor = Dino::Components::OneWire.new(pin: @pins[:temperature_pin], board: @board)
    @sensors = {temperature: temperature_sensor}
  end

  def update_relay_states
    if @latest_sensor_data >= @goal_state + 1
      puts "freezer should go on"
      @freezer.on unless @freezer_on
      @freezer_on = true
    elsif @latest_sensor_data < @goal_state - 1
      puts "freezer should go off"
      @freezer.off if @freezer_on
      @freezer_on = false
    end
    FridgeApiClient.post_data_point 'freezer', @freezer_on
  end
end
