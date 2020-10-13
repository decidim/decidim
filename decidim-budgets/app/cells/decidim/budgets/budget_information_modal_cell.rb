# frozen_string_literal: true

module Decidim
  module Budgets
    # This cell renders the Budgets component "More information" modal dialog
    class BudgetInformationModalCell < BaseCell
      alias budget model

      def more_information
        translated_attribute(current_settings.more_information_modal).presence || translated_attribute(settings.more_information_modal)
      end

      def component_name
        translated_attribute(current_component.name)
      end

      def i18n_scope
        "decidim.budgets.budget_information_modal"
      end
    end
  end
end
