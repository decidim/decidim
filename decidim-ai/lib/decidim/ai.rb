# frozen_string_literal: true

require "decidim/ai/engine"

module Decidim
  module Ai
    autoload :StrategyRegistry, "decidim/ai/strategy_registry"
    autoload :SpamDetection, "decidim/ai/spam_detection/spam_detection"
    autoload :LanguageDetection, "decidim/ai/language_detection/language_detection"

    include ActiveSupport::Configurable

    config_accessor :trained_models do

      ActiveSupport::Deprecation.warn("This should be deprecated")
      @models = Decidim::Ai::SpamDetection.resource_models
      @models.merge(Decidim::Ai::SpamDetection.user_models)

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
        user = organization.users.find_or_initialize_by(email: Decidim::Ai::SpamDetection.reporting_user_email)
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
