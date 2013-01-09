%w(logger rubygems bundler/setup celluloid).each do |lib|
  require lib
end

class SetpointUpdater
  include Celluloid

  def initialize(client)
    @client = client
  end

  def regularly_update_set_points
    loop do
      get_set_points
      sleep 30
    end
  end

  private

    def get_set_points
      humidistat.goal_state = 50
      thermostat.goal_state = 13
      # set_points = client.get_set_points
      # humidistat.goal_state = set_points['humidity'].to_f
      # thermostat.goal_state = set_points['temperature'].to_f
    rescue => e
      LOGGER.error "#{Time.current} = #{e}"
    end

end
