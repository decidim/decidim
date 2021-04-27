# frozen_string_literal: true

module Decidim
  module Votings
    # The data store for an Election Closure.
    class PollingStationClosure < ApplicationRecord
      enum phase: [:envelopes, :results, :attachment, :sign, :freezed], _suffix: true

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

      # Public: Checks if the closure has been signed by the polling officer or not.
      #
      # Returns Boolean.
      def signed?
        signed_at.present?
      end
    end
  end
end
