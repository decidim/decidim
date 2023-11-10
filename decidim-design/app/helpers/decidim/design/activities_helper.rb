# frozen_string_literal: true

module Decidim
  module Design
    module ActivitiesHelper
      def activities_sections
        [
          {
            id: "demo",
            contents: [
              {
                type: :text,
                values: ["This cell receives a model of LastActivity items and displays the following elements:"]
              },
              {
                type: :partial,
                template: "decidim/design/components/activities/static-activities"
              },
              {
                type: :text,
                values: ["Used by the last activity page, in a content block and within the dropdowns."]
              },
            ]
          },
          {
            id: "sourcecode",
            contents: [
              {
                type: :table,
                options: { headings: %w(Cell Code) },
                items: activities_table(
                  { name: "Activities", url: "https://github.com/decidim/decidim/blob/develop/decidim-core/app/cells/decidim/activities_cell.rb" },
                  { name: "Activitiy", url: "https://github.com/decidim/decidim/blob/develop/decidim-core/app/cells/decidim/activity_cell.rb" }
                )
              }
            ]
          }
        ]
      end

      def activities_table(*table_rows, **_opts)
        table_rows.map do |table_cell|
          row = []
          row << table_cell[:name]
          row << link_to(table_cell[:url].split("/").last, table_cell[:url], target: "_blank", class: "text-secondary underline", rel: "noopener")
          row
        end
      end
    end
  end
end
