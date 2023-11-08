# frozen_string_literal: true

module Decidim
  module Design
    module AuthorHelper
      def author_sections
        [
          {
            id: "context",
            contents: [
              {
                type: :text,
                values: [
                  "This cell display some information about a user. It a visual help to identify the resource/content creator.
                    Hovering with the mouse displays a tooltip with further info and links to its profile",
                  "For resources, this cell appears beneath the main heading. For other contents, it appears next to the content itself."
                ]
              }
            ]
          },
          {
            id: "variations",
            contents: [
              {
                type: :text,
                values: ["There are three different versions of this cell. Each one fits better regarding the context it is being displayed."]
              },
              {
                values: section_subtitle(title: "Default")
              },
              {
                type: :partial,
                template: "decidim/design/components/author/static-default"
              },
              {
                type: :text,
                values: ["Calling the cell with no extra arguments, but the user itself."]
              },
              {
                values: section_subtitle(title: "Compact")
              },
              {
                type: :partial,
                template: "decidim/design/components/author/static-compact"
              },
              {
                type: :text,
                values: ["Appending <code>layout: :compact</code> to the cell arguments will display the author version that identifies the resource creator."]
              },
              {
                values: section_subtitle(title: "Avatar")
              },
              {
                type: :partial,
                template: "decidim/design/components/author/static-avatar"
              },
              {
                type: :text,
                values: ["Appending <code>layout: :avatar</code> shows only the picture.
                          Often it is used when there are narrow spaces, where the author is a secondary information"]
              },
            ]
          },
        ]
      end

      def author_table(*table_rows, **_opts)
        table_rows.each_with_index.map do |table_cell, _ix|
          row = []
          row
        end
      end
    end
  end
end
