# frozen_string_literal: true

module Decidim
  module Votings
    class EnvelopesResultForm < Decidim::Form
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
        return unless total_ballots_count

        total_ballots_count != election_votes_count
      end

      def election
        @election ||= Decidim::Elections::Election.find_by(id: election_id)
      end

      def polling_station
        @polling_station ||= Decidim::Votings::PollingStation.find_by(id: polling_station_id)
      end
    end
  end
end
