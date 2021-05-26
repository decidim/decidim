# frozen_string_literal: true

module Decidim
  module Votings
    class BallotStyleQuestion < ApplicationRecord
      # This is a join table between Decidim::Votings::BallotStyle and Decidim::Elections::Question
      belongs_to :ballot_style, class_name: "Decidim::Votings::BallotStyle", foreign_key: :decidim_votings_ballot_style_id
      belongs_to :question, class_name: "Decidim::Elections::Question", foreign_key: :decidim_elections_question_id
    end
  end
end
