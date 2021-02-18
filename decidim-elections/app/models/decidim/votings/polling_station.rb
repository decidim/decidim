# frozen_string_literal: true

module Decidim
  module Votings
    # The data store for a PollingStation in the Votings::Voting partecipatory space.
    class PollingStation < ApplicationRecord
      include Traceable
      include Loggable
      include Decidim::TranslatableResource

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

      validate :polling_station_managers_same_voting
      validate :polling_station_president_same_voting

      # Allow ransacker to search for a key in a hstore column (`title`.`en`)
      ransacker :title do |parent|
        Arel::Nodes::InfixOperation.new("->>", parent.table[:title], Arel::Nodes.build_quoted(I18n.locale.to_s))
      end

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
