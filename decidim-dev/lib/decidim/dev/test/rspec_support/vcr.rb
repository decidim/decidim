# frozen_string_literal: true

require "vcr"

module BulletinBoardVcr
  def self.bulletin_board_uri?(uri)
    uri.hostname == bulletin_board_uri.hostname && uri.port == bulletin_board_uri.port
  end

  def self.bulletin_board_uri
    @bulletin_board_uri ||= URI(bulletin_board_server)
  end

  def self.bulletin_board_server
    return "" unless defined?(Decidim::Elections)

    Decidim::Elections.bulletin_board.server
  end
end

VCR.configure do |config|
  config.default_cassette_options = { serialize_with: :json }
  config.cassette_library_dir = "spec/cassettes"
  config.hook_into :webmock
  config.configure_rspec_metadata!
  config.ignore_request { |request| !BulletinBoardVcr.bulletin_board_uri?(URI(request.uri)) }
end
