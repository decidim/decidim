# frozen_string_literal: true

require "classifier-reborn"

module Decidim
  module Ai
    module SpamContent
      class BayesStrategy < BaseStrategy
        def initialize(options = {})
          super
          @options = { adapter: :memory, categories: %w(ham spam), params: {} }.deep_merge(options)

          @available_categories = options[:categories]
          @backend = ClassifierReborn::Bayes.new(*available_categories, backend: configured_backend)
        end

        delegate :train, :untrain, to: :backend

        def log
          return unless category

          "The Classification engine marked this as #{category}"
        end

        def classify(content)
          @category, @internal_score = backend.classify_with_score(content)
          category
        end

        # The Bayes strategy returns a score between that can be lower than -1
        # As per ClassifierReborn documentation, closest to 0 is being picked as the dominant category
        #
        # From original documentation:
        #   Returns the scores in each category the provided +text+. E.g.,
        #     b.classifications "I hate bad words and you"
        #       =>  {"Uninteresting"=>-12.6997928013932, "Interesting"=>-18.4206807439524}
        #   The largest of these scores (the one closest to 0) is the one picked out by #classify
        def score
          category.presence == "Spam" ? 1 : 0
        end

        private

        attr_reader :backend, :options, :available_categories, :category, :internal_score

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
