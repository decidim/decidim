# frozen_string_literal: true

module Decidim
  module Design
    module ActivitiesHelper
      def activities_sections
        [
          {
            id: t(".demo"),
            contents: [
              {
                type: :text,
                values: [t(".demo_text")]
              },
              {
                type: :partial,
                template: "decidim/design/components/activities/static-activity"
              },
              {
                type: :text,
                values: [t(".demo_text_2")]
              }
            ]
          },
          {
            id: t(".variations"),
            contents: [
              {
                type: :text,
                values: [t(".variations_text")]
              },
              {
                type: :partial,
                template: "decidim/design/components/activities/static-activity"
              }
            ]
          },
          {
            id: t(".source_code"),
            contents: [
              {
                type: :cell_table,
                options: { headings: [t(".activities")] },
                cell_snippet: {
                  cell: "decidim/activities",
                  args: [Decidim::ActionLog.where(resource_type: "Decidim::ParticipatoryProcess", organization: current_organization).first(5)],
                  call_string: 'cell("decidim/activities", _ACTION_LOG_ITEMS_LIST)'
                }
              },
              {
                type: :cell_table,
                options: { headings: [t(".activity")] },
                cell_snippet: {
                  cell: "decidim/activity",
                  args: [Decidim::ActionLog.where(resource_type: "Decidim::ParticipatoryProcess", organization: current_organization).last],
                  call_string: 'cell("decidim/activity", _ACTION_LOG_ITEM_)'
                }
              }
            ]
          }
        ]
      end
    end
  end
end
