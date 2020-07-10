# frozen_string_literal: true

module Decidim
  module Budgets
    # This cell renders the Budgets component "More information" modal dialog
    class BudgetInformationModalCell < BudgetsHeaderCell
      alias budget model

      def more_information
        translated_attribute(current_settings.more_information).presence || translated_attribute(settings.more_information)
      end

      def component_name
        translated_attribute(current_component.name)
      end

      def discardable
        @discardable ||= if should_discard_to_vote?
                           current_workflow.discardable - [budget]
                         else
                           []
                         end
      end

      def order_path_for
        budget_order_path(budget, return_path: request.path)
      end

      def should_discard_to_vote?
        limit_reached? && current_workflow.vote_allowed?(budget, false)
      end

      def i18n_scope
        "decidim.budgets.budget_information_modal"
      end
    end
  end
end
