# frozen_string_literal: true

module Decidim
  module Forms
    class AnswerChoice < Forms::ApplicationRecord
      belongs_to :answer,
                 class_name: "Answer",
                 foreign_key: "decidim_answer_id"

      belongs_to :answer_option,
                 class_name: "AnswerOption",
                 foreign_key: "decidim_answer_option_id"
    end
  end
end
