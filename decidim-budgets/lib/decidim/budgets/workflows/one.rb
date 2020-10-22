# frozen_string_literal: true

module Decidim
  module Budgets
    module Workflows
      # This Workflow allows users to vote in any budget, but only in one.
      class One < Base
        # No budget resource is highlighted for this workflow.
        def highlighted?(_resource)
          false
        end

        # Users can vote in any budget with this workflow, but only in one.
        def vote_allowed?(resource, consider_progress: true)
          return false if voted.any?

          if consider_progress
            progress?(resource) || progress.none?
          else
            true
          end
        end

        # Public: Returns a list of budgets where the user can discard their order to vote in another.
        #
        # Returns Array.
        def discardable
          progress + voted
        end
      end
    end
  end
end
