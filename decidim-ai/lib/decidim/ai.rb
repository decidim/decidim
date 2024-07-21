# frozen_string_literal: true

require "decidim/ai/engine"

module Decidim
  module Ai
    autoload :StrategyRegistry, "decidim/ai/strategy_registry"
    autoload :SpamDetection, "decidim/ai/spam_detection/spam_detection"
    autoload :LanguageDetection, "decidim/ai/language_detection/language_detection"

    include ActiveSupport::Configurable
  end
end
