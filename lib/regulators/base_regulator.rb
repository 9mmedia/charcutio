class BaseRegulator
  attr_accessor :goal_state
  attr_reader :sensor_data

  def initialize(fridge)
    @fridge = fridge
    @board = fridge.board
    @pins = fridge.pins
    set_relays
    set_sensors
  end

  def maintain_goal_state
    setup_sensor_callbacks
    Thread.new do
      update_relay_states
      sleep 30
    end
  end

  def on_sensor_data(sensor_name, sensor)
    sensor.when_data_received sensor_callback(sensor_name)
  end

  def set_relays
    # override
  end

  def set_sensors
    # override
  end

  def update_relay_states
    # override
  end

  private

    def sensor_callback(sensor_name)
      Proc.new do |data|
        puts "#{sensor_name}: #{data}"
        File.open("tmp/#{sensor_name}", 'w') { |f| f.puts data }
        # @fridge.client.post_sensor_data(sensor_name, sensor_data)
      end
    end

    def setup_sensor_callbacks
      @sensors.each do |sensor_name, sensor|
        on_sensor_data(sensor_name, sensor)
      end
    end
end
