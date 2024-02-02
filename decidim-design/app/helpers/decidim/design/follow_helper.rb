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
                type: :cell_table,
                options: { headings: ["Follow Button"] },
                cell_snippet: {
                  cell: "decidim/follow_button",
                  args: [Decidim::User.where.not(id: current_user&.id).first],
                  call_string: 'cell("decidim/follow_button", _FOLLOWABLE_RESOURCE_)'
                }
              }
            ]
          }
        ]
      end
    end
  end
end
