# frozen_string_literal: true

module Decidim
  module Elections
    # The data store for a Question in the Decidim::Elections component. It stores a
    # title and a maximum number of selection that voters can choose.
    class Question < ApplicationRecord
      include Decidim::Resourceable
      include Traceable
      include Loggable

      belongs_to :election, foreign_key: "decidim_elections_election_id", class_name: "Decidim::Elections::Election", inverse_of: :questions
      has_many :answers, foreign_key: "decidim_elections_question_id", class_name: "Decidim::Elections::Answer", inverse_of: :question, dependent: :destroy
      has_many :results, foreign_key: "decidim_elections_question_id", class_name: "Decidim::Elections::Result", dependent: :destroy
      has_one :component, through: :election, foreign_key: "decidim_component_id", class_name: "Decidim::Component"

      default_scope { order(weight: :asc, id: :asc) }

      # Public: Checks if enough answers are given for max_selections attribute
      #
      # Returns a boolean.
      def valid_max_selection?
        max_selections <= answers.count
      end

      # Public: Checks if the question accepts a blank/NOTA as an answer
      #
      # Returns a boolean.
      def nota_option?
        @nota_option ||= min_selections.zero?
      end

      def blank_votes
        @blank_votes ||= results.blank_answers.sum(:value)
      end

      def results_total
        @results_total ||= answers.sum(&:results_total) + blank_votes
      end

      # A result percentage relative to the question
      # Returns a Float.
      def blank_votes_percentage
        @blank_votes_percentage ||= results_total.positive? ? (blank_votes.to_f / results_total * 100.0).round : 0
      end

      def slug
        "question-#{id}"
      end
    end
  end
end
