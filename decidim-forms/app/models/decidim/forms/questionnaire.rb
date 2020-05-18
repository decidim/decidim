# frozen_string_literal: true

module Decidim
  module Forms
    # The data store for a Questionnaire in the Decidim::Forms component.
    class Questionnaire < Forms::ApplicationRecord
      belongs_to :questionnaire_for, polymorphic: true

      has_many :questions, -> { order(:position) }, class_name: "Question", foreign_key: "decidim_questionnaire_id", dependent: :destroy
      has_many :answers, class_name: "QuestionnaireAnswer", foreign_key: "decidim_questionnaire_id", dependent: :destroy
      has_many :question_answers, class_name: "Answer", foreign_key: "decidim_questionnaire_id", dependent: :destroy

      default_scope { order(weight: :asc, id: :asc) }

      # Public: returns whether the questionnaire questions can be modified or not.
      def questions_editable?
        answers.empty?
      end

      # Public: returns whether the questionnaire is answered by the user or not.
      def answered_by?(user)
        query = user.is_a?(String) ? { session_token: user } : { user: user }
        answers.where(query).any?
      end

      def sibling_questionnaires
        self.class.where(questionnaire_for: questionnaire_for)
      end

      def previous_step_id
        sibling_questionnaires_ids[step_index - 1]
      end

      def next_step_id
        sibling_questionnaires_ids[step_index + 1]
      end

      def step_index
        sibling_questionnaires_ids.index(id)
      end

      def first_step?
        id == sibling_questionnaires_ids.first
      end

      def last_step?
        id == sibling_questionnaires_ids.last
      end

      def sibling_questionnaires_ids
        @sibling_questionnaires_ids ||= sibling_questionnaires.pluck(:id)
      end
    end
  end
end
