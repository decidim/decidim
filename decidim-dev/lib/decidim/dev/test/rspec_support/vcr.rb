# frozen_string_literal: true

require "vcr"

VCR.configure do |config|
  config.default_cassette_options = { serialize_with: :json }
  config.cassette_library_dir = "spec/cassettes"
  config.hook_into :webmock
  config.configure_rspec_metadata!
  config.ignore_request do |request|
    if defined?(Decidim::Elections)
      URI(request.uri).port != URI(Decidim::Elections.bulletin_board.server).port
    else
      true
    end
  end
end
