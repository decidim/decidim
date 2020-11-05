# frozen_string_literal: true

module Decidim
  module Budgets
    module Workflows
      # This Workflow allows users to vote in all budgets.
      class All < Base
        # No budget is highlighted for this workflow.
        def highlighted?(_resource)
          false
        end

        # Users can vote in all budgets with this workflow.
        def vote_allowed?(resource, _consider_progress = true)
          !voted?(resource)
        end
      end
    end
  end
end
