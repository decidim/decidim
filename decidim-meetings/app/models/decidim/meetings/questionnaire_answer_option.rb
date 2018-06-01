# frozen_string_literal: true

module Decidim
  module Meetings
    class QuestionnaireAnswerOption < Meetings::ApplicationRecord
      belongs_to :question, class_name: "QuestionnaireQuestion", foreign_key: "decidim_meetings_questionnaire_question_id"
    end
  end
end
