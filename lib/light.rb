
class Light

  def initialize(charcutio)
    @charcutio = charcutio
    @board = charcutio.board
    @pins = charcutio.pins[:light_pins].split(",").map(&:strip)
    @lights = @pins.map { |pin| Dino::Components::Led.new(pin: pin, board: @board) }
    @state = :off
  end

  def on?
    @state == :on
  end

  def off?
    !on?
  end

  def on
    @lights.each { |l| l.send(:on) }
    @state = :on
    self
  end

  def off
    @lights.each { |l| l.send(:off) }
    @state = :off
    self
  end
end