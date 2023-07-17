# frozen_string_literal: true

require "decidim/ai/engine"

module Decidim
  module Ai
    autoload :LanguageDetectionService, "decidim/ai/language_detection_service"
    autoload :SpamDetectionService, "decidim/ai/spam_detection_service"
    autoload :StrategyRegistry, "decidim/ai/strategy_registry"

    module SpamContent
      autoload :BaseStrategy, "decidim/ai/spam_content/base_strategy"
    end

    include ActiveSupport::Configurable

    # Language detection service class.
    #
    # If you want to autodetect the language of the content, you can use a class service having the following contract
    #
    # class LanguageDetectionService
    #   def initialize(text)
    #     @text = text
    #   end
    #
    #   def language_code
    #     CLD.detect_language(@text).fetch(:code)
    #   end
    # end
    config_accessor :language_detection_service do
      "Decidim::Ai::LanguageDetectionService"
    end

    # Spam detection service class.
    # If you want to use a different spam detection service, you can use a class service having the following contract
    #
    # class SpamDetectionService
    #   def initialize
    #     @registry = Decidim::Ai.spam_detection_registry
    #   end
    #
    #   def train(category, text)
    #     # train the strategy
    #   end
    #
    #   def classify(text)
    #     # classify the text
    #   end
    #
    #   def untrain(category, text)
    #     # untrain the strategy
    #   end
    #
    #   def classification_log
    #     # return the classification log
    #   end
    # end
    config_accessor :spam_detection_service do
      "Decidim::Ai::SpamDetectionService"
    end

    # This is the email address used by the spam engine to
    # properly identify the user that will report users and content
    config_accessor :reporting_user_email do
      "reporting.user@domain.tld"
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
