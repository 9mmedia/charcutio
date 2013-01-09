
# Handles taking pictures of the meat and sending them to the meat server!
class MeatPhotographer
  include Celluloid

  def initialize(webcam)
    @webcam = webcam
  end

  def run
    # FIXME should have this stuff scheduled a better way
    sleep 5 # give the dino components time to init
    # take pics twice a day
    every (60 * 60 * 12), post_new_meatshot
  end

  def post_new_meatshot
    Proc.new do
      post_meatshot new_meatshot
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
