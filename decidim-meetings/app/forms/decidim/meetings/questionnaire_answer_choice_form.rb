# frozen_string_literal: true

module Decidim
  module Meetings
    # This class holds a Form to update questionnaire question answer options
    class QuestionnaireAnswerChoiceForm < Decidim::Form
      attribute :body, String
      attribute :custom_body, String
      attribute :position, Integer
      attribute :answer_option_id, Integer

      validates :answer_option_id, presence: true
    end
  end
end
