# frozen_string_literal: true

module Decidim
  module Budgets
    module Groups
      module Workflows
        # This Workflow for Budgets Groups allow users to vote in all budgets.
        class All < Base
          # No budgets component is highlighted for this workflow.
          def highlighted?(_component)
            false
          end

          # Users can vote in all budgets components with this workflow.
          def vote_allowed?(component, _consider_progress = true)
            !voted?(component)
          end
        end
      end
    end
  end
end
