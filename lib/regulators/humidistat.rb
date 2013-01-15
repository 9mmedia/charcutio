class Humidistat < BaseRegulator

  def latest_sensor_data=(value)
    @latest_sensor_data = value.match(/\|(.+)/)[1].to_f
  end

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
    if @latest_sensor_data <= @goal_state - 5
      puts "humidifier should go on"
      humidify
    elsif @latest_sensor_data >= @goal_state + 5
      puts "dehumidifier should go on"
      dehumidify
    elsif @humidifier_on && @latest_sensor_data >= @goal_state - 3
      puts "humidifier should go off"
      @humidifier.off
      @humidifier_on = false
    elsif @dehumidifier_on && @latest_sensor_data <= @goal_state - 3
      puts "dehumidifier should go off"
      @dehumidifier.off
      @dehumidifier_on = false
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
