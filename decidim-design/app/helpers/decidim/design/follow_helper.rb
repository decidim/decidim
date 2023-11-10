# frozen_string_literal: true

module Decidim
  module Design
    module FollowHelper
      def follow_sections
        [
          {
            id: "usage",
            contents: [
              {
                type: :text,
                values: ["Make sure the partial <code>decidim/shared/login_modal</code> is present in the DOM.
                          This partial is placed in the application layout when the user is logged in."]
              },
              {
                type: :table,
                options: { headings: ["Follow Button"] },
                items: follow_table(
                  { partial: "decidim/design/components/follow/static-follow-default" },
                  { partial: "decidim/design/components/follow/static-follow-unfollow" }
                ),
                cell_snippet: {
                  cell: "decidim/follow_button",
                  args: [Decidim::User.first]
                }
              }
            ]
          }
        ]
      end

      def follow_table(*table_rows, **_opts)
        table_rows.map do |table_cell|
          row = []
          row << render(partial: table_cell[:partial])
          row
        end
      end
    end
  end
end
