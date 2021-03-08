# frozen_string_literal: true

module Decidim
  module Elections
    module Votes
      # A class used to find votes of a specific election
      class ElectionVotes < Rectify::Query
        def initialize(election)
          @election = election
        end

        # Finds the votes for the given election
        def query
          Decidim::Elections::Vote.where(election: @election)
        end
      end
    end
  end
end
