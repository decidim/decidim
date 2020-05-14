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
          def vote_allowed?(_component, _consider_progress = true)
            true
          end
        end
      end
    end
  end
end
