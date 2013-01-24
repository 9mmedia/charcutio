class Thermostat < BaseRegulator

  def sensor_name
    'temperature'
  end

  def set_relays
    @freezer = Dino::Components::Led.new(pin: @pins[:freezer_pin], board: @board) if @pins[:freezer_pin]
  end

  def update_relay_states
    if @latest_sensor_data >= @goal_state + 0.5
      unless @freezer_on
        puts "freezer should go on"
        @freezer.on
        @freezer_on = true
      end
    elsif @latest_sensor_data < @goal_state
      if @freezer_on
        puts "freezer should go off"
        @freezer.off
        @freezer_on = false
      end
    end
    FridgeApiClient.post_data_point 'freezer', @freezer_on
  end
end
