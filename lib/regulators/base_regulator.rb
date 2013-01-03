class BaseRegulator
  def initialize(fridge)
    @fridge = fridge
    @board = fridge.board
    @pins = fridge.pins
    set_relays
    set_sensors
  end

  def maintain_goal_state
    setup_sensor_callbacks
    sleep 5
    Thread.new do
      loop do
        update_relay_states
        @fridge.post_data_point sensor_name, latest_sensor_data
        sleep 10 # should be 30
      end
    end
  end

  private

    def setup_sensor_callbacks
      @sensors.each do |sensor_name, sensor|
        @fridge.register_sensor(sensor_name, sensor)
      end
    end
end
