# frozen_string_literal: true

module Decidim
  module Votings
    # The data store for a Polling Station Closure.
    class PollingStationClosure < ApplicationRecord
      include Decidim::HasAttachments
      enum phase: [:count, :results, :certificate, :signature, :complete], _suffix: true

      belongs_to :election,
                 foreign_key: "decidim_elections_election_id",
                 class_name: "Decidim::Elections::Election"
      belongs_to :polling_station,
                 foreign_key: "decidim_votings_polling_station_id",
                 class_name: "Decidim::Votings::PollingStation"
      belongs_to :polling_officer,
                 foreign_key: "decidim_votings_polling_officer_id",
                 class_name: "Decidim::Votings::PollingOfficer",
                 optional: true
      has_many :results,
               foreign_type: "closurable_type",
               class_name: "Decidim::Elections::Result",
               dependent: :destroy,
               as: :closurable

      delegate :organization, to: :election

      # Public: Checks if the closure has been signed by the polling officer or not.
      #
      # Returns Boolean.
      def signed?
        signed_at.present?
      end

      # Public: Checks if the closure has been validated by the monitoring committee or not.
      #
      # Returns Boolean.
      def validated?
        validated_at.present?
      end
    end
  end
end
