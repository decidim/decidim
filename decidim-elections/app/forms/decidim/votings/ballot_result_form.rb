# frozen_string_literal: true

module Decidim
  module Votings
    class BallotResultForm < Decidim::Form
      attribute :valid_ballots_count, Integer
      attribute :blank_ballots_count, Integer
      attribute :null_ballots_count, Integer
      attribute :total_ballots_count, Integer

      validates :valid_ballots_count,
                :blank_ballots_count,
                :null_ballots_count,
                presence: true,
                numericality: true

      validate :ballot_total_count

      def ballot_total_count
        total_ballots_count == (valid_ballots_count + blank_ballots_count + null_ballots_count)
      end

      def map_model(model)
        # self.valid_ballots_count = model.results.valid_ballots.first&.votes_count.to_i
        # self.blank_ballots_count = model.results.blank_ballots.first&.votes_count.to_i
        # self.null_ballots_count = model.results.null_ballots.first&.votes_count.to_i
        self.total_ballots_count = model.results&.total_ballots&.first&.votes_count.to_i
      end
    end
  end
end
