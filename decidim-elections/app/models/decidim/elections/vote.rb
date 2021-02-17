# frozen_string_literal: true

module Decidim
  module Elections
    # The data store for a Vote in the Decidim::Election component. It stores the hash computed from the `encrypted_vote` associated to a particular `voter_id`.
    class Vote < ApplicationRecord
      enum status: [:pending, :accepted, :rejected].map { |status| [status, status.to_s] }.to_h

      belongs_to :election, foreign_key: "decidim_elections_election_id", class_name: "Decidim::Elections::Election"
      belongs_to :user, foreign_key: "decidim_user_id", class_name: "Decidim::User"

      validates :voter_id, :encrypted_vote_hash, presence: true
    end
  end
end
