# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rails/test_help"

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# Load fixtures from the engine
if ActiveSupport::TestCase.method_defined?(:fixture_path=)
  ActiveSupport::TestCase.fixture_path = File.expand_path("../fixtures/", __FILE__)
end

# Refer to https://github.com/rails/rails/issues/4971
module OpenBadges
  class ActionController::TestCase
    setup do
      @routes = Engine.routes
    end
  end
end

class ActionController::TestCase
  include Devise::TestHelpers
end

# Declare constants to be used in tests
SMILEY_IMAGE_PATH = File.join(Rails.root, "/app/assets/Smiley_face.png")