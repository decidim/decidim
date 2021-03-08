# frozen_string_literal: true

module Decidim
  module Elections
    module Votes
      # A class used to find votes for a specific user and election
      class UserElectionLastVote < Rectify::Query
        def initialize(user, election)
          @user = user
          @election = election
        end

        def query
          Rectify::Query
            .merge(
              ElectionVotes.new(@election),
              UserVotes.new(@user)
            )
            .query
            .order("created_at")
            .last
        end
      end
    end
  end
end
