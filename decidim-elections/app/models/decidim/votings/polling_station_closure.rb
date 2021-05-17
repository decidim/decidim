# frozen_string_literal: true

module Decidim
  module Votings
    # The data store for an Election Closure.
    class PollingStationClosure < ApplicationRecord
      enum phase: [:envelopes, :results, :attachment, :confirmed, :freeze], _suffix: true

      belongs_to :election,
                 foreign_key: "decidim_elections_election_id",
                 class_name: "Decidim::Elections::Election",
                 inverse_of: :ps_closures
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
    end
  end
end
