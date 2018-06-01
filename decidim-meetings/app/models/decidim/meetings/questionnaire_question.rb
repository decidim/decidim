# frozen_string_literal: true

module Decidim
  module Meetings
    # The data store for a QuestionnaireQuestion in the Decidim::Meetings component.
    class QuestionnaireQuestion < Meetings::ApplicationRecord
      TYPES = %w(short_answer long_answer single_option multiple_option sorting).freeze

      belongs_to :questionnaire, class_name: "Questionnaire", foreign_key: "decidim_meetings_questionnaire_id"

      has_many :answer_options,
               class_name: "QuestionnaireAnswerOption",
               foreign_key: "decidim_meetings_questionnaire_question_id",
               dependent: :destroy,
               inverse_of: :question

      validates :question_type, inclusion: { in: TYPES }

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
    end
  end
end
