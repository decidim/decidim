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
                  args: [shareable_resource],
                  call_string: 'cell("decidim/share_widget", resource)'
                }
              }
            ]
          }
        ]
      end

      protected

      def shareable_resource
        return Decidim::Debates::Debate.last if Decidim.module_installed?(:debates)
        return Decidim::Meetings::Meeting.last if Decidim.module_installed?(:meetings)
        return Decidim::Proposals::Proposal.last if Decidim.module_installed?(:proposals)
      end
    end
  end
end
