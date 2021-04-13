# frozen_string_literal: true

module Decidim
  module Elections
    # The data store for a Question in the Decidim::Elections component. It stores a
    # title, description and a maximum number of selection that voters can choose.
    class Question < ApplicationRecord
      include Decidim::Resourceable
      include Traceable
      include Loggable

      belongs_to :election, foreign_key: "decidim_elections_election_id", class_name: "Decidim::Elections::Election", inverse_of: :questions
      has_many :answers, foreign_key: "decidim_elections_question_id", class_name: "Decidim::Elections::Answer", inverse_of: :question, dependent: :destroy

      has_many :ballot_style_questions,
               class_name: "Decidim::Votings::BallotStyleQuestion",
               foreign_key: :decidim_elections_question_id,
               inverse_of: :question,
               dependent: :delete_all
      has_many :ballot_styles, through: :ballot_style_questions

      has_one :component, through: :election, foreign_key: "decidim_component_id", class_name: "Decidim::Component"

      default_scope { order(weight: :asc, id: :asc) }

      # Public: Checks if enough answers are given for max_selections attribute
      #
      # Returns a boolean.
      def valid_max_selection?
        max_selections <= answers.count
      end

      def results_total
        answers.sum(&:results_total)
      end

      def slug
        "question-#{id}"
      end
    end
  end
end
