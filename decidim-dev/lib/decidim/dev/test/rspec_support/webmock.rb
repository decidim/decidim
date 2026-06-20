# frozen_string_literal: true

require "webmock/rspec"

class CleanUpValidatorHtmlUri
  def self.host
    validator_html_uri = ENV.fetch("VALIDATOR_HTML_URI", nil)
    return if validator_html_uri.to_s.empty?

    URI.parse(validator_html_uri).host
  rescue URI::InvalidURIError
    nil
  end
end

WebMock.disable_net_connect!(
  allow_localhost: true,
  allow: [
    %r{https://validator\.w3\.org/},
    CleanUpValidatorHtmlUri.host,
    Decidim::Dev::Test::MapServer.host
  ].compact
)
