# frozen_string_literal: true

require "vcr"

VCR.configure do |config|
  config.default_cassette_options = { serialize_with: :json }
  config.cassette_library_dir = "spec/cassettes"
  config.hook_into :webmock
  config.allow_http_connections_when_no_cassette = true
end
