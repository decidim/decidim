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

        private

        def render_dropdown(component:, resource_id:, filters:)
          render partial: "decidim/admin/exports/dropdown", locals: { component:, resource_id:, filters:, extra_export_links: }
        end

        def extra_export_links
          [
            {
              type: :projects,
              format: :pb,
              format_name: t("decidim.budgets.admin.exports.formats.pabulib"),
              href: budget_pabulib_export_path(budget)
            }
          ]
        end
      end
    end
  end
end
