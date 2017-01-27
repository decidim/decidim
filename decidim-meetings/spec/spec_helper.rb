ENV["ENGINE_NAME"] = File.dirname(File.dirname(__FILE__)).split("/").last
require "decidim/dev/test/base_spec_helper"

require "webmock/rspec"
WebMock.allow_net_connect!

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }
