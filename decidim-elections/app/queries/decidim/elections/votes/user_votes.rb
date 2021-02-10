# frozen_string_literal: true

module Decidim
  module Elections
    module Votes
      # A class used to find votes for a specific user
      class UserVotes < Rectify::Query
        def initialize(user)
          @user = user
        end

        # Finds the votes for a specific user
        def query
          Decidim::Elections::Vote.where(user: @user)
        end
      end
    end
  end
end
