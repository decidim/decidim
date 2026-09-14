# frozen_string_literal: true

require "rotp"

module Decidim
  module TwoFactorTestHelpers
    def totp_code_for(secret)
      ROTP::TOTP.new(secret).now
    end
  end
end

RSpec.configure do |config|
  config.include Decidim::TwoFactorTestHelpers
end
