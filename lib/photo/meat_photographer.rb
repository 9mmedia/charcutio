
# Handles taking pictures of the meat and sending them to the meat server!
class MeatPhotographer
  include Celluloid

  def initialize(webcam)
    @webcam = webcam
    take_regularly_scheduled_photos
  end

  def take_regularly_scheduled_photos
    # FIXME should have this stuff scheduled a better way
    sleep 5 # give the dino components time to init
    # take pics twice a day
    take_and_post_meatshot
    every(60 * 60 * 12) { take_and_post_meatshot }
  end

  def take_and_post_meatshot
    post_meatshot new_meatshot rescue nil
  end

  private

    def new_meatshot
      @webcam.meatshot
    end

    def post_meatshot(file_name)
      FridgeApiClient.post_meatshot file_name
    end

end
