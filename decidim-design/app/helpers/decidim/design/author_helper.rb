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
                values: cell("decidim/author", user_item)
              },
              {
                type: :text,
                values: ["Calling the cell with no extra arguments, but the user itself."]
              },
              {
                values: section_subtitle(title: "Compact")
              },
              {
                values: cell("decidim/author", user_item, from: authored_item, context_actions: [:date], layout: :compact)
              },
              {
                type: :text,
                values: ["This author version is the common way to identify the resource creator."]
              },
              {
                values: section_subtitle(title: "Avatar")
              },
              {
                values: cell("decidim/author", user_item, layout: :avatar)
              },
              {
                type: :text,
                values: ["It is used when there are narrow spaces, where the author is a secondary information."]
              }
            ]
          },
          {
            id: "source_code",
            contents: [
              {
                type: :text,
                values: [""],
                cell_snippet: {
                  cell: "decidim/author",
                  args: [user_item],
                  call_string: [
                    'cell("decidim/author", _USER_PRESENTER_)',
                    'cell("decidim/author", _USER_PRESENTER_, from: _AUTHORABLE_OR_COAUTHORABLE_RESOURCE_, context_actions: [:date], layout: :compact)',
                    'cell("decidim/author", _USER_PRESENTER_, layout: :avatar)'
                  ]
                }
              }
            ]
          }
        ]
      end

      def user_item
        Decidim::User.new(
          organization: current_organization,
          id: 2000,
          email: "alan_smith@example.org",
          confirmed_at: Time.current,
          name: "Alan Smith",
          nickname: "alan_smith",
          personal_url: "https://alan.example.org",
          about: "Hi, I am Alan",
          accepted_tos_version: Time.current
        ).presenter
      end

      class AuthoredItem
        ATTRS = [:published_at].freeze

        attr_reader(*ATTRS)

        def initialize(args = {})
          args.slice(*ATTRS).each do |var, val|
            instance_variable_set(:"@#{var}", val)
          end
        end
      end

      def authored_item
        AuthoredItem.new(
          published_at: 1.day.ago
        )
      end
    end
  end
end
