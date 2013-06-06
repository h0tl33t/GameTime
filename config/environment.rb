# Load the rails application.
require File.expand_path('../application', __FILE__)

# Initialize the rails application.
GameTime::Application.initialize!

GameTime::Application.configure do
	config.time_zone = 'Eastern Time (US & Canada)'
end
