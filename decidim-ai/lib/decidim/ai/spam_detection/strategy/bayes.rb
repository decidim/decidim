# frozen_string_literal: true

require "classifier-reborn"

module Decidim
  module Ai
    module SpamDetection
      module Strategy
        class Bayes < Base
          def initialize(options = {})
            super
            @options = { adapter: :memory, categories: [:ham, :spam], params: {} }.deep_merge(options)

            @available_categories = options[:categories]
            @backend = ClassifierReborn::Bayes.new(*available_categories, backend: configured_backend)
          end

          def log
            return unless category

            "The Classification engine marked this as #{category}"
          end

          # Calling this method without any trained categories will throw an error
          def untrain(category, content)
            return unless backend.categories.collect(&:downcase).collect(&:to_sym).include?(category)

            backend.untrain(category, content)
          end

          delegate :train, :reset, to: :backend

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
            category.presence == "spam" ? 1 : 0
          end

          private

          attr_reader :backend, :options, :available_categories, :category, :internal_score

          def configured_backend
            if options[:adapter].to_s == "memory"
              system_log "[decidim-ai] #{self.class.name} - Running the Memory backend as it was requested. This is not recommended for production environment."
              ClassifierReborn::BayesMemoryBackend.new
            elsif options.dig(:params, :url) && options.dig(:params, :url).empty?
              system_log "[decidim-ai] #{self.class.name} - Running the Memory backend as there are no redis credentials. This is not recommended for production environment."
              ClassifierReborn::BayesMemoryBackend.new
            else
              system_log "[decidim-ai] #{self.class.name} - Running the Redis backend"
              ClassifierReborn::BayesRedisBackend.new options[:params]
            end
          end

          def system_log(message)
            Rails.logger.info message
          end
        end
      end
    end
  end
end
