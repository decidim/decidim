# frozen_string_literal: true

module Decidim
  module Forms
    # The data store for a Question in the Decidim::Forms component.
    class Question < Forms::ApplicationRecord
      include Decidim::TranslatableResource

      QUESTION_TYPES = %w(short_response long_response single_option multiple_option sorting files matrix_single matrix_multiple).freeze
      SEPARATOR_TYPE = "separator"
      TITLE_AND_DESCRIPTION_TYPE = "title_and_description"
      TYPES = (QUESTION_TYPES + [SEPARATOR_TYPE, TITLE_AND_DESCRIPTION_TYPE]).freeze

      translatable_fields :body, :description

      belongs_to :questionnaire, class_name: "Questionnaire", foreign_key: "decidim_questionnaire_id"

      has_many :matrix_rows,
               class_name: "QuestionMatrixRow",
               foreign_key: "decidim_question_id",
               dependent: :destroy,
               inverse_of: :question

      has_many :response_options,
               class_name: "ResponseOption",
               foreign_key: "decidim_question_id",
               dependent: :destroy,
               inverse_of: :question

      # Conditions to display this question in questionnaire
      has_many :display_conditions,
               class_name: "DisplayCondition",
               foreign_key: "decidim_question_id",
               dependent: :destroy,
               inverse_of: :question

      # Conditions to display other questions based on the value of this question's response
      has_many :display_conditions_for_other_questions,
               class_name: "DisplayCondition",
               foreign_key: "decidim_condition_question_id",
               dependent: :destroy,
               inverse_of: :question,
               counter_cache: :display_conditions_for_other_questions_count

      # Questions which have display conditions based on the value of this question's response
      has_many :conditioned_questions,
               through: :display_conditions_for_other_questions,
               foreign_key: "decidim_condition_question_id",
               class_name: "Question"

      has_many :responses,
               class_name: "Response",
               foreign_key: "decidim_question_id",
               dependent: :destroy,
               inverse_of: :question

      validates :question_type, inclusion: { in: TYPES }

      scope :not_separator, -> { where.not(question_type: SEPARATOR_TYPE) }
      scope :not_title_and_description, -> { where.not(question_type: TITLE_AND_DESCRIPTION_TYPE) }

      scope :with_body, -> { where(question_type: %w(short_response long_response)) }
      scope :with_choices, -> { where.not(question_type: %w(short_response long_response)) }

      scope :conditioned, -> { includes(:display_conditions).where.not(decidim_forms_display_conditions: { id: nil }) }
      scope :not_conditioned, -> { includes(:display_conditions).where(decidim_forms_display_conditions: { id: nil }) }

      def matrix?
        %w(matrix_single matrix_multiple).include?(question_type)
      end

      def multiple_choice?
        %w(single_option multiple_option sorting matrix_single matrix_multiple).include?(question_type)
      end

      def mandatory_body?
        mandatory? && !multiple_choice? && !has_attachments?
      end

      def mandatory_choices?
        mandatory? && multiple_choice? && !has_attachments?
      end

      def number_of_options
        response_options.size
      end

      def translated_body
        Decidim::Forms::QuestionPresenter.new(self).translated_body
      end

      def separator?
        question_type.to_s == SEPARATOR_TYPE
      end

      def title_and_description?
        question_type.to_s == TITLE_AND_DESCRIPTION_TYPE
      end

      def has_attachments?
        question_type.to_s == "files"
      end

      def responses_count
        questionnaire.responses.where(question: self).count
      end

      def self.log_presenter_class_for(_log)
        Decidim::Forms::AdminLog::QuestionPresenter
      end
    end
  end
end
