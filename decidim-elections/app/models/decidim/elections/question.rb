# frozen_string_literal: true

module Decidim
  module Elections
    class Question < ApplicationRecord
      include Decidim::TranslatableResource

      QUESTION_TYPES = %w(single_option multiple_option).freeze

      belongs_to :election, class_name: "Decidim::Elections::Election", inverse_of: :questions

      has_many :response_options, class_name: "Decidim::Elections::ResponseOption", dependent: :destroy, inverse_of: :question

      validates :question_type, inclusion: { in: QUESTION_TYPES }

      translatable_fields :body, :description

      validates :body, presence: true

      scope :enabled, -> { where.not(voting_enabled_at: nil) }
      scope :disabled, -> { where(voting_enabled_at: nil) }
      scope :published_results, -> { where.not(published_results_at: nil) }
      scope :unpublished_results, -> { where(published_results_at: nil) }

      default_scope { order(position: :asc) }

      def presenter
        Decidim::Elections::QuestionPresenter.new(self)
      end

      def voting_enabled?
        voting_enabled_at.present?
      end

      def can_enable_voting?
        return false unless election.ongoing?

        !voting_enabled?
      end

      def published_results?
        published_results_at.present?
      end

      def publishable_results?
        return false if published_results?

        case election.results_availability
        when "per_question"
          voting_enabled?
        when "after_end"
          election.ready_to_publish_results?
        else
          false
        end
      end
    end
  end
end
