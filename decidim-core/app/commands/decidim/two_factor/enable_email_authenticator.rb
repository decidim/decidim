# frozen_string_literal: true

module Decidim
  module TwoFactor
    # Turns on the one-time code sent to the account email.
    class EnableEmailAuthenticator < EnrollAuthenticator
      protected

      def enroll = EmailAuthenticator.create!(user:)
    end
  end
end
