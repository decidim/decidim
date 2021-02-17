# frozen_string_literal: true

module Decidim
  module Votings
    # The data store for a PollingStation in the Votings::Voting partecipatory space.
    class PollingStation < ApplicationRecord
      include Traceable
      include Loggable

      belongs_to :voting, foreign_key: "decidim_votings_voting_id", class_name: "Decidim::Votings::Voting", inverse_of: :polling_stations
      has_many :polling_station_managers,
               foreign_key: "managed_polling_station_id",
               class_name: "Decidim::Votings::PollingOfficer",
               inverse_of: :managed_polling_station,
               dependent: :nullify
      has_one :polling_station_president,
              foreign_key: "presided_polling_station_id",
              class_name: "Decidim::Votings::PollingOfficer",
              inverse_of: :presided_polling_station,
              dependent: :nullify

      validate :polling_station_managers_same_voting
      validate :polling_station_president_same_voting

      geocoded_by :address

      private

      # Private: check if the president is in the same voting
      def polling_station_president_same_voting
        return if polling_station_president.nil?

        errors.add(:polling_station_president, :different_voting) unless voting == polling_station_president.voting
      end

      # Private: check if the managers are in the same voting
      def polling_station_managers_same_voting
        return if polling_station_managers.empty?

        errors.add(:polling_station_managers, :different_voting) unless polling_station_managers.all? { |manager| manager.voting == voting }
      end
    end
  end
end
