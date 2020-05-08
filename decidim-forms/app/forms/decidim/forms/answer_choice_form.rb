# frozen_string_literal: true

module Decidim
  module Forms
    # This class holds a Form to save the chosen option for an answer
    class AnswerChoiceForm < Decidim::Form
      attribute :body, String
      attribute :custom_body, String
      attribute :position, Integer
      attribute :answer_option_id, Integer
      attribute :matrix_row_id, Integer

      validates :answer_option_id, presence: true
    end
  end
end
