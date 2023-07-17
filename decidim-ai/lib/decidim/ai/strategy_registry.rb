# frozen_string_literal: true

module Decidim
  module Ai
    class StrategyRegistry
      class StrategyAlreadyRegistered < StandardError; end

      def register_analyzer(name, klass, options = {})
        if strategies[name].present?
          raise(
            StrategyAlreadyRegistered,
            "There is a stategy already registered with the name `:#{name}`"
          )
        end

        strategies[name] = klass.new(options)
      end

      def for(name)
        strategies[name]
      end

      def all
        strategies
      end

      delegate :empty?, :size, :each, :clear, to: :strategies

      private

      def strategies
        @strategies ||= {}
      end
    end
  end
end
