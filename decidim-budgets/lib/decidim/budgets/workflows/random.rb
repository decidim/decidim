# frozen_string_literal: true

module Decidim
  module Budgets
    module Workflows
      # This Workflow allows users to vote only in one budget, selected randomly.
      #
      # Note: random selection should be deterministic for the same user and the same budgets component.
      # As the budget resources list could change and affect the random selection, it also allows to finish orders created on other budgets.
      class Random < Base
        # Highlight the resource if the user didn't vote and is allowed to vote on it.
        def highlighted?(resource)
          vote_allowed?(resource)
        end

        # User can vote in the resource where they have an order in progress or in the randomly selected resource.
        def vote_allowed?(resource, consider_progress = true)
          return false if voted.any?

          if consider_progress
            progress?(resource) || (progress.none? && resource == random_resource)
          else
            resource == random_resource
          end
        end

        private

        def random_resource
          @random_resource ||= budgets.reorder(id: :asc).to_a[user.id % budgets.count] if user
        end
      end
    end
  end
end
