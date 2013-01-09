class SetpointUpdater
  include Celluloid

  def initialize(client)
    @client = client
  end

  def regularly_update_set_points
    loop do
      update_set_points
      sleep 30
    end
  end

  private

    def update_set_points
      Celluloid::Actor[:humidistat].goal_state = 50
      Celluloid::Actor[:thermostat].goal_state = 13
      # set_points = client.get_set_points
      # Celluloid::Actor[:humidistat].goal_state = set_points['humidity'].to_f
      # Celluloid::Actor[:thermostat].goal_state = set_points['temperature'].to_f
    rescue => e
      LOGGER.error "#{Time.current} = #{e}"
    end

end
