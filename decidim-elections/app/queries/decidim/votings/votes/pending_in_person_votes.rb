# frozen_string_literal: true

module Decidim
  module Votings
    module Votes
      # A class used to find in person votes with a pending status
      class PendingInPersonVotes < Decidim::Query
        # Syntactic sugar to initialize the class and return the queried objects.
        def self.for
          new.query
        end

        # Finds the in person votes with pending status
        def query
          Decidim::Votings::InPersonVote.pending
        end
      end
    end
  end
end
