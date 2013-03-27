class Humidistat < BaseRegulator

  def latest_sensor_data=(value)
    @latest_sensor_data = ((value.to_f/1024.0)*5.0 - 0.826)/0.0315
  end

  def sensor_name
    'humidity'
  end

  def set_relays
    @humidifier = Dino::Components::Led.new(pin: @pins[:humidifier_pin], board: @board) if @pins[:humidifier_pin]
    @dehumidifier = Dino::Components::Led.new(pin: @pins[:dehumidifier_pin], board: @board) if @pins[:dehumidifier_pin]
  end

  def update_relay_states
    @coasting_start_time = nil if coasting_period_over?
    if @latest_sensor_data <= @goal_state - 5 && !coasting_needed?
      puts "humidifier should go on"
      humidify
    elsif @latest_sensor_data >= @goal_state + 5 && !coasting_needed?
      puts "dehumidifier should go on"
      dehumidify
    elsif @humidifier_on && @latest_sensor_data >= @goal_state - 3
      puts "humidifier should go off"
      turn_off_both_relays
    elsif @dehumidifier_on && @latest_sensor_data <= @goal_state - 3
      puts "dehumidifier should go off"
      turn_off_both_relays
    end
    FridgeApiClient.post_data_point 'humidifier', @humidifier_on
    FridgeApiClient.post_data_point 'dehumidifier', @dehumidifier_on
  end

  private

    def coasting_needed?
      @coasting_start_time || @dehumidifier_on || @humidifier_on
    end

    def coasting_period_over?
      @coasting_start_time && Time.now.to_i >= @coasting_start_time.to_i + 60 * 5
    end

    def dehumidify
      @humidifier.off if @humidifier_on
      @dehumidifier.on unless @dehumidifier_on
      @humidifier_on, @dehumidifier_on = false, true
    end

    def humidify
      @humidifier.on unless @humidifier_on
      @dehumidifier.off if @dehumidifier_on
      @humidifier_on, @dehumidifier_on = true, false
    end

    def turn_off_both_relays
      @humidifier.off if @humidifier_on
      @dehumidifier.off if @dehumidifier_on
      @coasting_start_time = Time.now if @humidifier_on || @dehumidifier_on
      @humidifier_on, @dehumidifier_on = false, false
    end
end
