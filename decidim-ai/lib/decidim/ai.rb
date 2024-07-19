# frozen_string_literal: true

require "decidim/ai/engine"

module Decidim
  module Ai
    autoload :StrategyRegistry, "decidim/ai/strategy_registry"
    autoload :SpamDetection, "decidim/ai/spam_detection/spam_detection"
    autoload :LanguageDetection, "decidim/ai/language_detection/language_detection"

    include ActiveSupport::Configurable

    # This is the email address used by the spam engine to
    # properly identify the user that will report users and content
    config_accessor :reporting_user_email do
      "reporting.user@domain.tld"
    end

    config_accessor :trained_models do
      @models = Decidim::Ai::SpamDetection.resource_models

      ActiveSupport::Deprecation.warn("This should be deprecated")
      
      @models["Decidim::UserGroup"] = "Decidim::Ai::SpamDetection::Resource::UserBaseEntity"
      @models["Decidim::User"] = "Decidim::Ai::SpamDetection::Resource::UserBaseEntity"

      @models
    end

    def self.spam_detection_instance
      @spam_detection_instance ||= Decidim::Ai::SpamDetection.resource_detection_service.new
    end

    def self.spam_detection_registry
      @spam_detection ||= Decidim::Ai::StrategyRegistry.new
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
