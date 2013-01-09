
# Handles taking pictures of the meat and sending them to the meat server!
class MeatPhotographer
  include Celluloid

  def initialize(webcam)
    @webcam = webcam
  end

  def take_regularly_scheduled_photos
    # FIXME should have this stuff scheduled a better way
    sleep 5 # give the dino components time to init
    # take pics twice a day
    post_meatshot new_meatshot
    every(60 * 60 * 12) { post_meatshot new_meatshot }
  end

  private

    def new_meatshot
      @webcam.meatshot
    end

    def post_meatshot(file_name)
      FridgeApiClient.post_meatshot file_name
    end

end
