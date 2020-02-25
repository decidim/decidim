# frozen_string_literal: true

module Decidim
  module Forms
    # The data store for a Question in the Decidim::Forms component.
    class Question < Forms::ApplicationRecord
      TYPES = %w(short_answer long_answer single_option multiple_option sorting).freeze

      belongs_to :questionnaire, class_name: "Questionnaire", foreign_key: "decidim_questionnaire_id"

      has_many :answer_options,
               class_name: "AnswerOption",
               foreign_key: "decidim_question_id",
               dependent: :destroy,
               inverse_of: :question

      has_many :display_conditions,
               class_name: "DisplayCondition",
               foreign_key: "decidim_question_id",
               dependent: :destroy,
               inverse_of: :question

      has_many :display_conditions_for_other_questions,
               class_name: "DisplayCondition",
               foreign_key: "decidim_condition_question_id",
               dependent: :destroy,
               inverse_of: :question

      has_many :conditioned_questions,
               through: :display_conditions_for_other_questions,
               foreign_key: "decidim_condition_question_id",
               class_name: "Question"

      validates :question_type, inclusion: { in: TYPES }

      scope :previous_to, ->(position) { where("position < ?", position || 0) }

      def multiple_choice?
        %w(single_option multiple_option sorting).include?(question_type)
      end

      def mandatory_body?
        mandatory? && !multiple_choice?
      end

      def mandatory_choices?
        mandatory? && multiple_choice?
      end

      def number_of_options
        answer_options.size
      end

      def translated_body
        Decidim::Forms::QuestionPresenter.new(self).translated_body
      end
    end
  end
end
