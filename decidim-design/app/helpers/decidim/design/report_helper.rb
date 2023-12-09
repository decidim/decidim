# frozen_string_literal: true

module Decidim
  module Design
    module ReportHelper
      def report_sections
        [
          {
            id: "usage",
            contents: [
              {
                type: :text,
                values: ["Report button launches a modal window to flag the current resource."]
              },
              {
                type: :table,
                options: { headings: ["Report Button"] },
                items: report_table({}),
                cell_snippet: {
                  cell: "decidim/report_button",
                  args: [Decidim::User.first]
                }
              }
            ]
          }
        ]
      end

      def report_table(*table_rows, **_opts)
        table_rows.each_with_index.map do
          row = []
          row << render(partial: "decidim/design/components/report/static-report")
          row
        end
      end
    end
  end
end
