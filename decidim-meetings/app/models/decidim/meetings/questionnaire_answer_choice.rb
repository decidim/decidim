# frozen_string_literal: true

module Decidim
  module Meetings
    class QuestionnaireAnswerChoice < Meetings::ApplicationRecord
      belongs_to :answer,
                 class_name: "QuestionnaireAnswer",
                 foreign_key: "decidim_meetings_questionnaire_answer_id"

      belongs_to :answer_option,
                 class_name: "QuestionnaireAnswerOption",
                 foreign_key: "decidim_meetings_questionnaire_answer_option_id"
    end
  end
end
