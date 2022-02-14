# frozen_string_literal: true

module Decidim
  module Elections
    module Votes
      # A class used to find the last vote casted by a voter in an election
      class LastVoteForVoter < Decidim::Query
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
          Decidim::Elections::Vote.where(election: @election, voter_id: @voter_id)
                                  .order("created_at")
                                  .last
        end
      end
    end
  end
end
