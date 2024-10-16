# frozen_string_literal: true

module Decidim
  module Ai
    module SpamDetection
      class Service
        def initialize(registry:)
          @registry = registry
        end

        def reset
          @registry.each do |strategy|
            next unless strategy.respond_to?(:reset)

            strategy.reset
          end
        end

        def train(category, text)
          text = formatter.cleanup(text)
          return if text.blank?

          @registry.each do |strategy|
            strategy.train(category, text)
          end
        end

        def classify(text)
          text = formatter.cleanup(text)
          return if text.blank?

          @registry.each do |strategy|
            strategy.classify(text)
          end
        end

        def untrain(category, text)
          text = formatter.cleanup(text)
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

        protected

        def formatter
          @formatter ||= Decidim::Ai::Language.formatter.safe_constantize&.new
        end
      end
    end
  end
end
