class BaseRegulator
  def initialize(charcutio)
    @charcutio = charcutio
    @board = charcutio.board
    @pins = charcutio.pins
    set_relays
    set_sensors
  end

  def maintain_goal_state
    setup_sensor_callbacks
    sleep 5
    Thread.new do
      loop do
        update_relay_states
        @charcutio.post_sensor_data sensor_name, latest_sensor_data
        sleep 10 # should be 30
      end
    end
  end

  private

    def on_sensor_data(sensor_name, sensor)
      sensor.when_data_received sensor_callback(sensor_name)
    end

    def sensor_callback(sensor_name)
      Proc.new do |data|
        puts "#{sensor_name}: #{data}"
        File.open("tmp/#{sensor_name}", 'w') { |f| f.puts data }
      end
    end

    def setup_sensor_callbacks
      @sensors.each do |sensor_name, sensor|
        on_sensor_data(sensor_name, sensor)
      end
    end
end
