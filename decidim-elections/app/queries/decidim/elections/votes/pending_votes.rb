# frozen_string_literal: true

module Decidim
  module Elections
    module Votes
      # A class used to find votes with a pending status
      class PendingVotes < Rectify::Query
        # Syntactic sugar to initialize the class and return the queried objects.
        def self.for
          new.query
        end

        # Finds the votes with pending status
        def query
          Decidim::Elections::Vote.pending
        end
      end
    end
  end
end
