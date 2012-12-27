class Humidistat < BaseRegulator
  attr_reader :dehumidifier, :humidifier, :humidity_sensor

  def goal_state=(value)
    File.open('tmp/humidity_goal', 'w') { |f| f.puts value }
  end

  def goal_state
    File.readlines('tmp/humidity_goal').first.to_f
  end

  def latest_sensor_data
    match = File.readlines('tmp/humidity').first.match(/\|(.+)/)
    match[1].to_f if match
  end

  def set_relays
    @humidifier = Dino::Components::Led.new(pin: @pins[:humidifier_pin], board: @board) if @pins[:humidifier_pin]
    @dehumidifier = Dino::Components::Led.new(pin: @pins[:dehumidifier_pin], board: @board) if @pins[:dehumidifier_pin]
  end

  def set_sensors
    @humidity_sensor = Dino::Components::DHT22.new(pin: @pins[:humidity_pin], board: @board)
    @sensors = {humidity: @humidity_sensor}
  end

  def update_relay_states
    current_data = latest_sensor_data
    goal = goal_state
    if current_data <= goal - 10
      puts "humidifier should go on"
      toggle_humidifier :on unless @humidifier_on
      toggle_dehumidifier :off if @dehumidifier_on
    elsif current_data >= goal + 10
      puts "dehumidifier should go on"
      toggle_humidifier :off if @humidifier_on
      toggle_dehumidifier :on unless @dehumidifier_on
    else
      puts "humidifier and dehumidifier should go off"
      toggle_dehumidifier :off if @dehumidifier_on
      toggle_humidifier :off if @humidifier_on
    end
  end

  private

    def toggle_dehumidifier(state)
      @dehumidifier_on = state == :on
      @dehumidifier.send state if @dehumidifier
    end

    def toggle_humidifier(state)
      @humidifier.send state
      @humidifier_on = state == :on if @humidifier
    end
end
