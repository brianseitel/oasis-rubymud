Dir["base/*.rb"].each do |file|
	require File.dirname(__FILE__) + "/#{file}"
end
Dir["models/*.rb"].each do |file|
	require File.dirname(__FILE__) + "/#{file}"
end
Dir["modules/*.rb"].each do |file|
	require File.dirname(__FILE__) + "/#{file}"
end



def setting(key)
	config = YAML::load(File.open('config/app.yml'))
	if (config.include? key)
		return config[key]
	end
	return nil
end

logger = Logger::new(STDOUT)
logger.sev_threshold = Logger::DEBUG

ActiveRecord::Base.logger = Logger.new(STDOUT)

Thread.abort_on_exception = true

MudServer.startup
