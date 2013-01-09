module SensorRegistrar

  def self.register_sensor(actor, sensor)
    sensor.when_data_received sensor_callback(actor)
  end

  def self.sensor_callback(actor)
    Proc.new do |data|
      begin
        actor.latest_sensor_data = data
      rescue Celluloid::DeadActorError => e
        # if there's an error, allow time for the respawn to take place
        sleep 0.05
      end
    end
  end
end
