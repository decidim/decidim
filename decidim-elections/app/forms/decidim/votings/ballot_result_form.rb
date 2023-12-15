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
        return if total_ballots_count == (valid_ballots_count.to_i + blank_ballots_count.to_i + null_ballots_count.to_i)

        errors.add(:base, :total_count_invalid)
        errors.add(:total_ballots_count, :invalid)
        errors.add(:valid_ballots_count, :invalid)
        errors.add(:blank_ballots_count, :invalid)
        errors.add(:null_ballots_count, :invalid)
      end

      # rubocop:disable Metrics/PerceivedComplexity
      # rubocop:disable Metrics/CyclomaticComplexity
      def map_model(model)
        self.total_ballots_count = model.results&.total_ballots&.first&.value || 0
        self.null_ballots_count = model.results&.null_ballots&.first&.value
        self.blank_ballots_count = model.results&.blank_ballots&.first&.value
        self.valid_ballots_count = model.results&.valid_ballots&.first&.value
      end
      # rubocop:enable Metrics/PerceivedComplexity
      # rubocop:enable Metrics/CyclomaticComplexity
    end
  end
end
