# frozen_string_literal: true

module Decidim
  module Votings
    # The data store for a PollingStation in the Votings::Voting partecipatory space.
    class PollingStation < ApplicationRecord
      include Traceable
      include Loggable
      include Decidim::TranslatableResource
      include Decidim::FilterableResource

      translatable_fields :title, :location, :location_hints

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
      has_many :in_person_votes,
               foreign_key: "decidim_votings_polling_station_id",
               class_name: "Decidim::Votings::InPersonVote",
               inverse_of: :polling_station,
               dependent: :restrict_with_exception
      has_many :closures,
               foreign_key: "decidim_votings_polling_station_id",
               class_name: "Decidim::Votings::PollingStationClosure",
               inverse_of: :polling_station,
               dependent: :restrict_with_exception
      validate :polling_station_managers_same_voting
      validate :polling_station_president_same_voting

      alias participatory_space voting

      # Allow ransacker to search for a key in a hstore column (`title`.`en`)
      ransacker_i18n :title

      [:manager, :president].each do |role|
        [:name, :email, :nickname].each do |field|
          ransacker "#{role}_#{field}".to_sym do
            Arel.sql("#{role}_user.#{field}")
          end
        end
      end

      geocoded_by :address

      def missing_officers?
        polling_station_president.nil? || polling_station_managers.empty?
      end

      def slug
        "polling_station_#{id}"
      end

      def closure_for(election)
        closures.find_by(election:)
      end

      def self.log_presenter_class_for(_log)
        Decidim::Votings::AdminLog::PollingStationPresenter
      end

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
