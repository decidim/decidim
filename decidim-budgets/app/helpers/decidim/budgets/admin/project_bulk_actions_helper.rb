# frozen_string_literal: true

module Decidim
  module Budgets
    module Admin
      module ProjectBulkActionsHelper
        def bulk_selections
          select(
            :selected,
            :value,
            [
              [t("projects.index.select_for_implementation", scope: "decidim.budgets.admin"), true],
              [t("projects.index.deselect_implementation", scope: "decidim.budgets.admin"), false]
            ]
          )
        end
      end
    end
  end
end
