# frozen_string_literal: true

module Decidim
  module Meetings
    class AnswerChoice < Meetings::ApplicationRecord
      belongs_to :answer,
                 class_name: "Decidim::Meetings::Answer",
                 foreign_key: "decidim_answer_id"

      belongs_to :answer_option,
                 class_name: "Decidim::Meetings::AnswerOption",
                 foreign_key: "decidim_answer_option_id"
    end
  end
end
