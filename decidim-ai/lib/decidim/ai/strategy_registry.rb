# frozen_string_literal: true

module Decidim
  module Ai
    class StrategyRegistry
      class StrategyAlreadyRegistered < StandardError; end

      delegate :clear, :collect, :each, :size, to: :strategies
      attr_reader :strategies

      def initialize
        @strategies = []
      end

      def register_analyzer(name:, strategy:, options: {})
        if self.for(name).present?
          raise(
            StrategyAlreadyRegistered,
            "There is a strategy already registered with the name `:#{name}`"
          )
        end

        options = { name: }.merge(options)
        strategies << strategy.new(options)
      end

      def for(name)
        strategies.select { |k, _v| k.name == name }.first
      end
    end
  end
end
