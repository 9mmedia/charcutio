class BaseRegulator
  include Celluloid

  def initialize(board, pins)
    @board = board
    @pins = pins
    set_relays
    set_sensors
  end

  def goal_state=(value)
    @goal_state = value
  end

  def latest_sensor_data=(value)
    @latest_sensor_data = value
  end

  def maintain_goal_state
    setup_sensor_callbacks
    sleep 5
    every(10) { update_relays_and_post_latest_sensor_data }
    # should be 30 in production
  end

  private

    def setup_sensor_callbacks
      @sensors.each do |sensor|
        SensorRegistrar.register_sensor Actor.current, sensor
      end
    end

    def update_relays_and_post_latest_sensor_data
      Proc.new do
        if @goal_state && @latest_sensor_data
          update_relay_states
          FridgeApiClient.post_data_point sensor_name, @latest_sensor_data
        end
      end
    end
end
