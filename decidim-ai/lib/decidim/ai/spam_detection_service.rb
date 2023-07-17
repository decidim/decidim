# frozen_string_literal: true

module Decidim
  module Ai
    class SpamDetectionService
      def initialize
        @registry = Decidim::Ai.spam_detection_registry
      end

      def train(category, text)
        @registry.each do |_name, strategy|
          strategy.train(category, text)
        end
      end

      def classify(text)
        @registry.each do |_name, strategy|
          strategy.classify(text)
        end
      end

      def untrain(category, text)
        @registry.each do |_name, strategy|
          strategy.untrain(category, text)
        end
      end

      def classification_log
        @classification_log = []
        @registry.each do |_name, strategy|
          @classification_log << strategy.log
        end
        @classification_log.join("\n")
      end
    end
  end
end
