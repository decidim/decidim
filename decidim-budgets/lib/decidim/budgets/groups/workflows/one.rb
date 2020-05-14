# frozen_string_literal: true

module Decidim
  module Budgets
    module Groups
      module Workflows
        # This Workflow for Budgets Groups allow users to vote in any budget, but only in one.
        class One < Base
          # No budgets component is highlighted for this workflow.
          def highlighted?(component)
            false
          end

          # Users can vote in any budgets components with this workflow, but only in one.
          def vote_allowed?(component, consider_progress: true)
            return true unless consider_progress

            orders.empty? || (orders[component.id] && orders.count == 1)
          end
        end
      end
    end
  end
end
