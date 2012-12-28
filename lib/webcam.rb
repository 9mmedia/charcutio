class Webcam

  def initialize(light)
    @light = light
  end

  # take a meatshot!
  def meatshot(options = {})
    options = defaults.merge(options)

    light_on = @light.on?
    begin
      @light.on unless light_on
      cmd = take_meatshot(options)
      raise "Error taking meatshot: #{$?}, command: #{cmd}" unless $?.to_i == 0
    ensure
      @light.off unless light_on
    end

    options[:output]
  end


  private

    def defaults
      # TODO play around with these defaults when LEDs are set
      {
        width: 864,
        height: 480,
        quality: 75,
        brightness: 80,
        contrast: 30,
        saturation: 60,
        gain: 10,
        output: "/home/pi/meatshots/meatshot_#{Time.now.strftime('%Y%m%d%H%M%S')}.jpg"
      }
    end

    def take_meatshot(options)
      cmd = "uvccapture
        -S#{options[:saturation]}
        -B#{options[:brightness]}
        -C#{options[:contrast]}
        -G#{options[:gain]}
        -q#{options[:quality]}
        -x#{options[:width]}
        -y#{options[:height]}
        -o#{options[:output]}"

      cmd = cmd.gsub(/\n/, "") # hack to strip newlines from more readable formatted command above
      `#{cmd}`
      cmd
    end
end

