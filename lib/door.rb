# door sensor is a force sensor, with values of 0 when not touched, and higher values when 
# activated. needs to be calibrarted based on how much force exists when door is open/closed
class Door
  OPEN_THRESHOLD = 50
  CLOSED_THRESHOLD = 200

  def initialize(charcutio)
    @charcutio = charcutio
    @board = charcutio.board
    @pin = charcutio.pins[:door_pin]
    @door_sensor = Dino::Components::Sensor.new(pin: pin, board: @board)
    @door_sensor.when_data_received(sensor_callback)
    @state = :closed
  end

  def open?
    @state == :open
  end

  def closed?
    @state == :closed
  end

  private

    def state=(new_state)
      if new_state != @state
        @charcutio.light.off if new_state == :closed
        @charcutio.light.on if new_state == :open
        @state = new_state
        puts "Door is now #{@state}"
      end
    end

    def sensor_callback
        Proc.new do |data|
          #puts "door #{data}"
          if data.to_i < OPEN_THRESHOLD
            state = :open
          elsif data.to_i > CLOSED_THRESHOLD
            state = :closed
          else
            #changing between states, or we get stuck here if calibration values are note right
          end
        end
    end

end