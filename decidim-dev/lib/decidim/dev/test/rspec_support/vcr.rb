# frozen_string_literal: true

require "vcr"

VCR.configure do |config|
  config.default_cassette_options = { serialize_with: :json }
  config.cassette_library_dir = "spec/cassettes"
  config.hook_into :webmock
  config.allow_http_connections_when_no_cassette = true
  config.configure_rspec_metadata!
  # config.preserve_exact_body_bytes do |http_message|
  #   http_message.body.encoding.name == "ASCII-8BIT" || !http_message.body.valid_encoding?
  # end
  config.ignore_request do |request|
    URI(request.uri).port != URI(Decidim::Elections.bulletin_board.server).port
  end
end
