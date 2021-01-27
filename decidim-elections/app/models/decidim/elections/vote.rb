# frozen_string_literal: true

module Decidim
  module Elections
    # The data store for a Vote in the Decidim::Election component. It stores the hash computed from the `encrypted_vote` associated to a particular `voter_id`.
    class Vote < ApplicationRecord
      PENDING_STATUS = "pending"
      ALLOWED_STATUS = [PENDING_STATUS].freeze

      belongs_to :election, foreign_key: "decidim_elections_election_id", class_name: "Decidim::Elections::Election"

      validates :voter_id, :encrypted_vote_hash, presence: true
      validates :status, inclusion: { in: ALLOWED_STATUS }
    end
  end
end
