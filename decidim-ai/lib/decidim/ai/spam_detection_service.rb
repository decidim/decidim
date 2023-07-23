# frozen_string_literal: true

module Decidim
  module Ai
    class SpamDetectionService
      def initialize
        @registry = Decidim::Ai.spam_detection_registry
      end

      def train(category, text)
        return if text.blank?

        @registry.each do |strategy|
          strategy.train(category, text)
        end
      end

      def classify(text)
        return if text.blank?

        @registry.each do |strategy|
          strategy.classify(text)
        end
      end

      def untrain(category, text)
        return if text.blank?

        @registry.each do |strategy|
          strategy.untrain(category, text)
        end
      end

      def score
        @registry.collect(&:score).inject(0.0, :+) / @registry.size
      end

      def classification_log
        @classification_log = []
        @registry.each do |strategy|
          @classification_log << strategy.log
        end
        @classification_log.join("\n")
      end
    end
  end
end
