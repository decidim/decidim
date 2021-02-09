# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      # A class used to find actions with a pending status
      class PendingActions < Rectify::Query
        # Syntactic sugar to initialize the class and return the queried objects.
        def self.for
          new.query
        end

        # Finds the votes with pending status
        def query
          Decidim::Elections::Action.pending
        end
      end
    end
  end
end
