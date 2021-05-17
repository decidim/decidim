# frozen_string_literal: true

module Decidim
  module Votings
    class BallotStyle < ApplicationRecord
      belongs_to :voting, foreign_key: :decidim_votings_voting_id, class_name: "Decidim::Votings::Voting"

      has_many :ballot_style_questions,
               class_name: "Decidim::Votings::BallotStyleQuestion",
               foreign_key: :decidim_votings_ballot_style_id,
               inverse_of: :ballot_style,
               dependent: :delete_all
      has_many :questions, through: :ballot_style_questions
      has_many :census_data,
               foreign_key: "decidim_votings_ballot_style_id",
               class_name: "Decidim::Votings::Census::Datum",
               inverse_of: :ballot_style,
               dependent: :nullify

      def slug
        "#{voting.slug}_#{code.parameterize}-#{id}"
      end

      def questions_for(election)
        questions.where(election: election)
      end
    end
  end
end
