class SetpointUpdater
  include Celluloid

  def initialize
    every(10) { update_set_points }
    # should be 30 in production
  end

  private

    def update_set_points
      Celluloid::Actor[:humidistat].goal_state = 70 if Celluloid::Actor[:humidistat]
      Celluloid::Actor[:thermostat].goal_state = 18 if Celluloid::Actor[:thermostat]
      # set_points = FridgeApiClient.get_set_points
      # Celluloid::Actor[:humidistat].goal_state = set_points['humidity'].to_f
      # Celluloid::Actor[:thermostat].goal_state = set_points['temperature'].to_f
    rescue => e
      Charcutio::LOGGER.error "#{Time.now}: #{e}"
      sleep 0.05
      retry
    end
end
