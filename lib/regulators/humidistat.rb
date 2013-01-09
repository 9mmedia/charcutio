class Humidistat < BaseRegulator

  def  sensor_name
    'humidity'
  end

  def set_relays
    @humidifier = Dino::Components::Led.new(pin: @pins[:humidifier_pin], board: @board) if @pins[:humidifier_pin]
    @dehumidifier = Dino::Components::Led.new(pin: @pins[:dehumidifier_pin], board: @board) if @pins[:dehumidifier_pin]
  end

  def set_sensors
    humidity_sensor = Dino::Components::DHT22.new(pin: @pins[:humidity_pin], board: @board)
    @sensors = {humidity: humidity_sensor}
  end

  def update_relay_states
    if @latest_sensor_data <= @goal_state - 10
      puts "humidifier should go on"
      humidify
    elsif @latest_sensor_data >= @goal_state + 10
      puts "dehumidifier should go on"
      dehumidify
    else
      puts "humidifier and dehumidifier should go off"
      turn_off_both_relays
    end
    FridgeApiClient.post_data_point 'humidifier', @humidifier_on
    FridgeApiClient.post_data_point 'dehumidifier', @dehumidifier_on
  end

  private

    def humidify
      @humidifier.on unless @humidifier_on
      @dehumidifier.off if @dehumidifier_on
      @humidifier_on, @dehumidifier_on = true, false
    end

    def dehumidify
      @humidifier.off if @humidifier_on
      @dehumidifier.on unless @dehumidifier_on
      @humidifier_on, @dehumidifier_on = false, true
    end

    def turn_off_both_relays
      @humidifier.off unless @humidifier_on
      @dehumidifier.off unless @dehumidifier_on
      @humidifier_on, @dehumidifier_on = false, false
    end
end
