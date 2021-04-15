# frozen_string_literal: true

module Decidim
  module Elections
    # The data store for an Election Closure.
    class Closure < ApplicationRecord
      belongs_to :election,
                 foreign_key: "decidim_elections_election_id",
                 class_name: "Decidim::Elections::Election",
                 inverse_of: :closures
      belongs_to :polling_station,
                 foreign_key: "decidim_votings_polling_station_id",
                 class_name: "Decidim::Votings::PollingStation",
                 optional: true
      belongs_to :polling_officer,
                 foreign_key: "decidim_votings_polling_officer_id",
                 class_name: "Decidim::Votings::PollingOfficer"

      has_many :results,
               foreign_key: "decidim_elections_closure_id",
               class_name: "Decidim::Elections::Result",
               dependent: :destroy
    end
  end
end
