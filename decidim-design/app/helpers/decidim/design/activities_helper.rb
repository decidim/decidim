# frozen_string_literal: true

module Decidim
  module Design
    module ActivitiesHelper
      def activities_sections
        [
          {
            id: "demo",
            contents: [
              {
                type: :text,
                values: ["This cell receives a model of LastActivity items and displays the following elements:"]
              },
              {
                type: :partial,
                template: "decidim/design/components/activities/static-activities"
              },
              {
                type: :text,
                values: ["Used by the last activity page, in a content block and within the dropdowns."]
              }
            ]
          },
          {
            id: "variations",
            contents: [
              {
                type: :text,
                values: ["Regarding the type of activity, the cell could show different content, reporting the distinct resources,
                          whether belong to a participatory space or not, has an author or not."]
              },
              {
                type: :partial,
                template: "decidim/design/components/activities/static-activity"
              }
            ]
          },
          {
            id: "source_code",
            contents: [
              {
                type: :cell_table,
                options: { headings: ["Activities"] },
                cell_snippet: {
                  cell: "decidim/activities",
                  args: [Decidim::ActionLog.where(resource_type: "Decidim::ParticipatoryProcess", organization: current_organization).first(5)],
                  call_string: 'cell("decidim/activities", _ACTION_LOG_ITEMS_LIST)'
                }
              },
              {
                type: :cell_table,
                options: { headings: ["Activity"] },
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
