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
                type: :cell_table,
                options: { headings: ["Report Button"] },
                cell_snippet: {
                  cell: "decidim/report_button",
                  args: [Decidim::User.first],
                  call_string: 'cell("decidim/report_button", _REPORTABLE_RESOURCE_)'
                }
              }
            ]
          }
        ]
      end
    end
  end
end
