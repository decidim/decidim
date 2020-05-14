# frozen_string_literal: true

module Decidim
  module Budgets
    module Groups
      module Workflows
        # This Workflow for Budgets Groups allow users to vote only in one budget, selected randomly.
        #
        # Note: random selection should be deterministic for the same user and the same budgets group. As the budgets components
        # list could change and affect the random selection, it also allows to finish orders created on any budgets component.
        class Random < Base
          # Highlight the component if the user didn't vote and is allowed to vote on it.
          def highlighted?(component)
            voted.none? && vote_allowed?(component)
          end

          # User can vote in the component where they has an order in progress or in the randomly selected component.
          def vote_allowed?(component, consider_progress = true)
            if consider_progress
              progress?(component) || (progress.none? && component == random_component)
            else
              component == random_component
            end
          end

          private

          def random_component
            @random_component ||= budgets.reorder(id: :asc).to_a[user.id % budgets.count] if user
          end
        end
      end
    end
  end
end
