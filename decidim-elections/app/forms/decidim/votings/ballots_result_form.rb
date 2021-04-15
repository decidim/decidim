# frozen_string_literal: true

module Decidim
  module Votings
    class BallotsResultForm < Decidim::Form
      attribute :polling_station_id, Integer
      attribute :election_id, Integer

      attribute :total_ballots_count, Integer
      attribute :polling_officer_notes, String
      attribute :election_votes_count, Integer

      validates :polling_station_id,
                :election_id,
                :total_ballots_count,
                presence: true

      validates :polling_officer_notes, presence: true, if: :totals_differ?

      def totals_differ?
        total_ballots_count.to_i != election_votes_count.to_i
      end

      def map_model(model)
        self.polling_station_id = model.polling_station.id
        self.election_id = model.election.id
        self.total_ballots_count = model.results&.total_ballots&.first&.votes_count.to_i
        self.election_votes_count = model.election.votes&.count
      end
    end
  end
end
