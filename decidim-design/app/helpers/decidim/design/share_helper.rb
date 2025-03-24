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
                  args: [shareable],
                  call_string: 'cell("decidim/share_widget", resource)'
                }
              }
            ]
          }
        ]
      end

      def shareable
        ShareableResource.new
      end

      class ShareableResourcePresenter < SimpleDelegator
        def title(*)
          __getobj__.title
        end
      end

      class ShareableResource
        def initialize
          @title = "Shareable Resource"
        end

        def presenter = ShareableResourcePresenter.new(self)

        def to_sgid = "#"

        def [](key); end

        attr_accessor :title
      end
    end
  end
end
