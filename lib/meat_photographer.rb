
# Handles taking pictures of the meat and sending them to the meat server!
class MeatPhotographer
  include Celluloid

  def initialize(webcam)
    @webcam = webcam
  end

  def run
    # FIXME should have this stuff scheduled a better way
    sleep 5 # give the dino components time to init
    loop do
      post_meatshot new_meatshot

      # take pics twice a day
      sleep 60 * 60 * 12
    end
  end

  private

    def new_meatshot
      @webcam.meatshot
    end

    def post_meatshot(file_name)
      FridgeApiClient.post_meatshot file_name
    end

end
