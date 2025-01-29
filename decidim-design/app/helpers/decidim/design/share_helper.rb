# frozen_string_literal: true

module Decidim
  module Design
    module ShareHelper
      def share_sections
        [
          {
            id: "usage",
            title: t("decidim.design.helpers.usage"),
            contents: [
              {
                type: :text,
                values: [t("decidim.design.helpers.share_usage_description_html")]
              },
              {
                type: :cell_table,
                options: { headings: [t("decidim.design.helpers.share_button")] },
                cell_snippet: {
                  cell: "decidim/share_widget",
                  args: [Decidim::Blogs::Post.last],
                  call_string: 'cell("decidim/share_widget", resource)'
                }
              }
            ]
          }
        ]
      end
    end
  end
end
