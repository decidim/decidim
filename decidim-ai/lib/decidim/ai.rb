# frozen_string_literal: true

require "decidim/ai/engine"

module Decidim
  module Ai
    autoload :StrategyRegistry, "decidim/ai/strategy_registry"
    autoload :SpamDetection, "decidim/ai/spam_detection/spam_detection"
    autoload :LanguageDetection, "decidim/ai/language_detection/language_detection"

    include ActiveSupport::Configurable

    def self.spam_detection_instance
      @spam_detection_instance ||= Decidim::Ai::SpamDetection.resource_detection_service.new
    end

    def self.spam_detection_registry
      @spam_detection ||= Decidim::Ai::StrategyRegistry.new
    end
  end
end
