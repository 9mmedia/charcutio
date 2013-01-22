module SensorRegistrar

  def self.register_sensor(actor, sensor)
    sensor.when_data_received sensor_callback(actor)
  end

  def self.sensor_callback(actor)
    Proc.new do |data|
      actor.latest_sensor_data = data
    end
  end
end
