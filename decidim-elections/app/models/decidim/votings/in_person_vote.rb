# frozen_string_literal: true

module Decidim
  module Votings
    # The data store for in person Votes in the Decidim::Votings space.
    class InPersonVote < ApplicationRecord
      enum status: [:pending, :accepted, :rejected]

      belongs_to :election, foreign_key: "decidim_elections_election_id", class_name: "Decidim::Elections::Election"
      belongs_to :user, foreign_key: "decidim_user_id", class_name: "Decidim::User", optional: true

      belongs_to :polling_station,
                 foreign_key: "decidim_votings_polling_station_id",
                 class_name: "Decidim::Votings::PollingStation"
      belongs_to :polling_officer,
                 foreign_key: "decidim_votings_polling_officer_id",
                 class_name: "Decidim::Votings::PollingOfficer"

      validates :voter_id, presence: true
    end
  end
end
