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


  end
end
