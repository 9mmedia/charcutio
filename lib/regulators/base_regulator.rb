class BaseRegulator
  include Celluloid

  def initialize(board, pins)
    @board = board
    @pins = pins
    set_relays
    every(10) { update_relays_and_post_latest_sensor_data }
  end

  def goal_state=(value)
    @goal_state = value
  end

  def latest_sensor_data=(value)
    @latest_sensor_data = value.to_f
  end

  private

    def update_relays_and_post_latest_sensor_data
      if @goal_state && @latest_sensor_data
        update_relay_states
        FridgeApiClient.post_data_point sensor_name, @latest_sensor_data
        @latest_sensor_data = nil
      end
    end
end
