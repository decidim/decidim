# frozen_string_literal: true

module Decidim
  module Elections
    class Question < ApplicationRecord
      include Decidim::Traceable
      include Decidim::TranslatableResource

      belongs_to :election, class_name: "Decidim::Elections::Election", inverse_of: :questions

      has_many :response_options, class_name: "Decidim::Elections::ResponseOption", dependent: :destroy, inverse_of: :question

      translatable_fields :body, :description

      validates :body, presence: true
      validate :valid_question_type

      scope :enabled, -> { where.not(voting_enabled_at: nil) }
      scope :disabled, -> { where(voting_enabled_at: nil) }
      scope :published_results, -> { where.not(published_results_at: nil) }
      scope :unpublished_results, -> { where(published_results_at: nil) }

      default_scope { order(position: :asc) }

      def self.question_types
        %w(single_option multiple_option).freeze
      end

      def max_votable_options
        return response_options.size if question_type == "multiple_option"

        1
      end

      def sibling_questions
        @sibling_questions ||= election.per_question? ? election.questions.enabled.unpublished_results : election.questions
      end

      def next_question
        sibling_questions.where("position > ?", position).first
      end

      def previous_question
        sibling_questions.where(position: ...position).last
      end

      def presenter
        Decidim::Elections::QuestionPresenter.new(self)
      end

      def voting_enabled?
        !published_results? && voting_enabled_at.present?
      end

      def can_enable_voting?
        return false unless election.ongoing?

        !voting_enabled?
      end

      def published_results?
        published_results_at.present?
      end

      def publishable_results?
        return false if published_results? || !election.per_question?

        voting_enabled?
      end

      # returns the selected responses for this question, ensuring that the responses are
      # valid for the current election and question type.
      def safe_responses(response_ids)
        return [] if response_ids.blank?

        response_ids = Array(response_ids)

        response_options.where(id: response_ids.take(max_votable_options))
      end

      private

      def valid_question_type
        return if question_type.blank? || self.class.question_types.include?(question_type)

        errors.add(:question_type, :invalid)
      end
    end
  end
end
