
# Handles taking pictures of the meat and sending them to the meat server!
class MeatPhotographer

  def initialize(webcam, api_client)
    @webcam = webcam
    @api_client = api_client
  end

  def run
    # FIXME should have this stuff scheduled a better way
    sleep 5 # give the dino components time to init
    Thread.new do
      loop do
        begin
          file_name = take_meatshot
          upload_meatshot(file_name)
        rescue => e
          puts "MeatPhotographer down! #{e}"
        end

        # take pics twice a day
        sleep 60 * 60 * 12
      end
    end
  end


  private

    def take_meatshot
      @webcam.meatshot
    end

    def upload_meatshot(file_name)
      @api_client.post_meatshot(file_name)
    end

end
