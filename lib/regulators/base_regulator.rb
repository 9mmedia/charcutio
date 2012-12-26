class BaseRegulator
  attr_accessor :goal_state

  def initialize(board, pins)
    @board = board
    @pins = pins
    set_relays
    set_sensors(pins)
  end

  def on_sensor_data(sensor)
    callback = Proc.new do |data|
      puts data
    end

    sensor.when_data_received(callback)
    sleep
  end

  def set_relays
    # override
  end

  def set_sensors
    # override
  end
end
