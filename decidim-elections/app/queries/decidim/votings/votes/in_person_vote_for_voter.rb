# frozen_string_literal: true

module Decidim
  module Votings
    module Votes
      # A class used to find a non-rejected in person vote registered for a voter in an election
      class InPersonVoteForVoter < Decidim::Query
        # Syntactic sugar to initialize the class and return the queried objects.
        #
        # election - the election where the vote was casted
        # voter_id - the identifier of the voter
        def self.for(election, voter_id)
          new(election, voter_id).query
        end

        def initialize(election, voter_id)
          @voter_id = voter_id
          @election = election
        end

        def query
          Decidim::Votings::InPersonVote.not_rejected.find_by(election: @election, voter_id: @voter_id)
        end
      end
    end
  end
end
