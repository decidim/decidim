# frozen_string_literal: true

module Decidim
  module Design
    module ReportHelper
      def report_sections
        [
          {
            title: t("decidim.design.helpers.usage"),
            contents: [
              {
                type: :text,
                values: [t("decidim.design.helpers.report_usage_description")]
              },
              {
                type: :cell_table,
                options: { headings: [t("decidim.design.helpers.report_button")] },
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
