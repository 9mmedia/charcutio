class SetpointUpdater
  include Celluloid

  def regularly_update_set_points
    every(10) { update_set_points }
    # should be 30 in production
  end

  private

    def update_set_points
      Celluloid::Actor[:humidistat].goal_state = 70 if Celluloid::Actor[:humidistat]
      Celluloid::Actor[:thermostat].goal_state = 13 if Celluloid::Actor[:thermostat]
      # set_points = FridgeApiClient.get_set_points
      # Celluloid::Actor[:humidistat].goal_state = set_points['humidity'].to_f
      # Celluloid::Actor[:thermostat].goal_state = set_points['temperature'].to_f
    rescue Celluloid::DeadActorError => e
      sleep 0.05  # time for the respawn to take place
    end
end
