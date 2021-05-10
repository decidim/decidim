# frozen_string_literal: true

module Decidim
  module Elections
    # The data store for a Result in the Decidim::Elections component.
    class Result < ApplicationRecord
      enum result_type: [:valid_answers, :blank_answers, :valid_ballots, :blank_ballots, :null_ballots, :total_ballots]

      belongs_to :closurable, polymorphic: true
      belongs_to :question,
                 foreign_key: "decidim_elections_question_id",
                 class_name: "Decidim::Elections::Question",
                 optional: true,
                 inverse_of: :results
      belongs_to :answer,
                 foreign_key: "decidim_elections_answer_id",
                 class_name: "Decidim::Elections::Answer",
                 optional: true,
                 inverse_of: :results
    end
  end
end
