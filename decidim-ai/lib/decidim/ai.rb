# frozen_string_literal: true

require "decidim/ai/engine"

module Decidim
  module Ai
    include ActiveSupport::Configurable

    # This is the email address used by the spam engine to
    # properly identify the user that will report users and content
    config_accessor :reporting_user_email do
      "reporting.user@domain.tld"
    end

    def self.create_reporting_users!
      Decidim::Organization.find_each do |organization|
        user = organization.users.find_or_initialize_by(email: Decidim::Ai.reporting_user_email)
        next if user.persisted?

        password = SecureRandom.hex(10)
        user.password = password
        user.password_confirmation = password

        user.deleted_at = Time.current
        user.tos_agreement = true
        user.name = ""
        user.skip_confirmation!
        user.save!
      end
    end
  end
end
