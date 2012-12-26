%w(rubygems bundler/setup dino rest_client lib/regulators).each do |lib|
  require lib
end

class Fridge
  def initialize(pins)
    @board = Dino::Board.new Dino::TxRx.new
    @pins = pins
    @weight_sensor = Dino::Components::Sensor.new(pin: @pins[:weight_pin], board: @board)
  end

  def humidistat
    @humidistat ||= Humidistat.new(@board, @pins)
  end

  def thermostat
    @thermostat ||= Thermostat.new(@board, @pins)
  end

  def run
    if @pins
      # do stuff
    end
  end
end


if __FILE__ == $0
  Fridge.new(ARGV[0] || {}).run
end
