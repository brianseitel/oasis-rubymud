Dir["base/*.rb"].each do |file|
	require File.dirname(__FILE__) + "/#{file}"
end
Dir["models/*.rb"].each do |file|
	require File.dirname(__FILE__) + "/#{file}"
end

DATA_DIR = File.expand_path(File.dirname(__FILE__)) + "/data/"

logger = Logger::new(STDOUT)
logger.sev_threshold = Logger::DEBUG

ActiveRecord::Base.logger = Logger.new(STDOUT)

Thread.abort_on_exception = true

MudServer.startup