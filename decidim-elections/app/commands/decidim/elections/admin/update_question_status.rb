# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      class UpdateQuestionStatus < Decidim::Command
        def initialize(action, question)
          @action = action.to_sym
          @question = question
        end

        def call
          return broadcast(:invalid) unless action.in?([:enable_voting, :publish_results])

          transaction do
            update_status
            question.save!
          end

          broadcast(:ok, question)
        rescue StandardError => e
          Rails.logger.error "#{e.class.name}: #{e.message}"
          broadcast(:invalid)
        end

        private

        attr_reader :action, :question

        def update_status
          case action
          when :enable_voting
            question.voting_enabled_at = Time.current
          when :publish_results
            question.published_results_at = Time.current
          end
        end
      end
    end
  end
end
