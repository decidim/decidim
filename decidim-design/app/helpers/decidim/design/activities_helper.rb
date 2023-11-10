# frozen_string_literal: true

module Decidim
  module Design
    module ActivitiesHelper
      def activities_sections
        [
          {
            id: "Demo",
            contents: [
              {
                type: :text,
                values: ["This cell receives a model of LastActivity items and displays the following elements:"]
              },
              {
                type: :partial,
                template: "decidim/design/components/activities/static-activities"
              }
            ]
          },
        ]
      end

      def activities_table(*table_rows, **_opts)
        table_rows.map do |table_cell|
          row = []
          row
        end
      end
    end
  end
end
