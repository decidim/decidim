# frozen_string_literal: true

module Decidim
  module Design
    module FollowHelper
      def follow_sections
        [
          {
            id: "usage",
            title: t("decidim.design.helpers.usage"),
            contents: [
              {
                type: :text,
                values: [t("decidim.design.helpers.follower_description_html")]
              },
              {
                type: :cell_table,
                options: { headings: [t("decidim.design.helpers.follow_button")] },
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
