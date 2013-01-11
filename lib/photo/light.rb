class Light

  def initialize(fridge)
    pins = fridge.pins[:light_pins].split(",").map(&:strip)
    if pins.count == 3
      @rgb_light = Dino::Components::RgbLed.new board: fridge.board, pins: {red: pins[0], green: pins[1], blue: pins[2]}
    else
      @lights = pins.map { |pin| Dino::Components::Led.new(pin: pin, board: fridge.board) }
    end
    @state = :off
  end

  def on?
    @state == :on
  end

  def off?
    !on?
  end

  def on
    @lights.each { |l| l.send(:on) } if @lights
    randomize_rgb_light_on if @rgb_light
    @state = :on
    self
  end

  def off
    @lights.each { |l| l.send(:off) } if @lights
    rgb_light_off if @rgb_light
    @state = :off
    self
  end

  private

    def random_rgb_states
      states = (0..2).map { |i| [Dino::Board::LOW, Dino::Board::HIGH].sample }
      # make sure to turn at least one pin on when turning the rgb_light
      states[0] = Dino::Board::HIGH unless states.include? Dino::Board::HIGH
      states.shuffle!
    end

    def randomize_rgb_light_on
      states = random_rgb_states
      @rgb_light.send :analog_write, states[0], @rgb_light.pins[:red]
      @rgb_light.send :analog_write, states[1], @rgb_light.pins[:green]
      @rgb_light.send :analog_write, states[2], @rgb_light.pins[:blue]
    end

    def rgb_light_off
      @rgb_light.send :analog_write, Dino::Board::LOW, @rgb_light.pins[:red]
      @rgb_light.send :analog_write, Dino::Board::LOW, @rgb_light.pins[:green]
      @rgb_light.send :analog_write, Dino::Board::LOW, @rgb_light.pins[:blue]
    end
end
