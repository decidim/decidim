# frozen_string_literal: true

require "classifier-reborn"

module Decidim
  module Ai
    module SpamContent
      class BayesStrategy < BaseStrategy
        def initialize(options = {})
          @options = { adapter: :memory, params: {} }.deep_merge(options)
          @backend = ClassifierReborn::Bayes.new :spam, :ham, backend: configured_backend
        end

        delegate :train, :untrain, :classify, to: :backend

        def log
          "The Classification engine marked this as ..."
        end

        private

        attr_reader :backend, :options

        def configured_backend
          if options[:adapter] == :redis
            ClassifierReborn::BayesRedisBackend.new options[:params]
          else
            ClassifierReborn::BayesMemoryBackend.new
          end
        end
      end
    end
  end
end
