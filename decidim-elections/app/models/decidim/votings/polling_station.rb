# frozen_string_literal: true

module Decidim
  module Votings
    # The data store for a PollingStation in the Votings::Voting partecipatory space.
    class PollingStation < ApplicationRecord
      include Traceable
      include Loggable

      belongs_to :voting, foreign_key: "decidim_votings_voting_id", class_name: "Decidim::Votings::Voting", inverse_of: :polling_stations

      geocoded_by :address
    end
  end
end
