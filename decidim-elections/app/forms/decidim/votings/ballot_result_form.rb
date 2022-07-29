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
        total_ballots_count == (valid_ballots_count.to_i + blank_ballots_count.to_i + null_ballots_count.to_i)
      end

      def map_model(model)
        self.total_ballots_count = model.results&.total_ballots&.first&.value || 0
        self.null_ballots_count = model.results&.null_ballots&.first&.value
        self.blank_ballots_count = model.results&.blank_ballots&.first&.value
        self.valid_ballots_count = model.results&.valid_ballots&.first&.value
      end
    end
  end
end
