# frozen_string_literal: true

module Decidim
  module Budgets
    module Groups
      # This cell renders the budgets list of a Budget group
      class BudgetsListCell < BaseCell
        delegate :budgets, to: :workflow_instance

        def heading
          translated_attribute(current_settings.list_heading).presence || translated_attribute(settings.list_heading)
        end
      end
    end
  end
end
