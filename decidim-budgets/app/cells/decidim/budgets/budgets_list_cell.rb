# frozen_string_literal: true

module Decidim
  module Budgets
    # This cell renders the budgets list of a Budget component
    class BudgetsListCell < BaseCell
      alias current_workflow model

      def heading
        translated_attribute(current_settings.list_heading).presence || translated_attribute(settings.list_heading)
      end
    end
  end
end
