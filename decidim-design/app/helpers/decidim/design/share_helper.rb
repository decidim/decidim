# frozen_string_literal: true

module Decidim
  module Design
    module ShareHelper
      def share_sections
        [
          {
            id: "usage",
            contents: [
              {
                type: :text,
                values: ["Make sure the partial <code>decidim/shared/share_modal</code> is present in the DOM. This partial is placed in the application layout."]
              },
              {
                type: :cell_table,
                options: { headings: ["Share Button"] },
                cell_snippet: {
                  cell: "decidim/share_button",
                  args: [],
                  call_string: 'cell("decidim/share_button", nil)'
                }
              }
            ]
          }
        ]
      end
    end
  end
end
