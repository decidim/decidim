# frozen_string_literal: true

module Decidim
  module TwoFactor
    # The email one-time-code factor.
    class EmailAuthenticator < Authenticator
      attribute :confirmed_at, default: -> { Time.current }
    end
  end
end
