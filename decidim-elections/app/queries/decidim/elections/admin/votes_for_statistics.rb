# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      # A class used to find election votes for statistics
      class VotesForStatistics < Decidim::Query
        # Syntactic sugar to initialize the class and return the queried object.
        def self.for(election)
          new(election).query
        end

        def initialize(election)
          @election = election
        end

        # Finds the votes for an election which get count for the statistics
        def query
          @election.votes.accepted.pick(Arel.sql("COUNT(id)"), Arel.sql("COUNT(distinct voter_id)"))
        end
      end
    end
  end
end
