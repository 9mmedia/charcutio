require File.expand_path('../../sensor_registrar', __FILE__)

class BaseRegulator
  include Celluloid

  def initialize(fridge)
    @fridge = fridge
    @board = fridge.board
    @pins = fridge.pins
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
    loop do
      update_relay_states
      @fridge.post_data_point sensor_name, latest_sensor_data
      sleep 10 # should be 30
    end
  end

  private

    def setup_sensor_callbacks
      @sensors.each do |sensor|
        SensorRegistrar.register_sensor Actor.current, sensor
      end
      sleep 5
    end
end
