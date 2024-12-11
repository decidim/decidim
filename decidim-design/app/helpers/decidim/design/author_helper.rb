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
                values: cell("decidim/author", user_item, demo: true)
              },
              {
                type: :text,
                values: ["Calling the cell with no extra arguments, but the user itself."]
              },
              {
                values: section_subtitle(title: "Compact")
              },
              {
                values: cell("decidim/author", user_item, from: authored_item, context_actions: [:date], layout: :compact, demo: true)
              },
              {
                type: :text,
                values: ["This author version is the common way to identify the resource creator."]
              },
              {
                values: section_subtitle(title: "Avatar")
              },
              {
                values: cell("decidim/author", user_item, layout: :avatar, demo: true)
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
              type: :table,
              options: { headings: %w(Card Code Usage) },
              items: author_table(
                { name: "Default", url: "https://github.com/decidim/decidim/tree/develop/decidim-core/app/cells/decidim/author",
                  usage: "https://github.com/decidim/decidim/blob/develop/decidim-core/app/cells/decidim/card_l/author.erb" },
                { name: "Compact", url: "https://github.com/decidim/decidim/tree/develop/decidim-core/app/cells/decidim/author",
                  usage: "https://github.com/decidim/decidim/blob/develop/decidim-blogs/app/views/decidim/blogs/posts/show.html.erb" },
                { name: "Avatar", url: "https://github.com/decidim/decidim/tree/develop/decidim-core/app/cells/decidim/author", usage: "https://github.com/decidim/decidim/blob/develop/decidim-core/app/cells/decidim/endorsers_list/show.erb" }
              )
            ]
          }
        ]
      end

      def author_table(*table_rows, **_opts)
        table_rows.map do |table_cell|
          row = []
          row << table_cell[:name]
          row << link_to(table_cell[:url].split("/").last, table_cell[:url], target: "_blank", class: "text-secondary underline", rel: "noopener")
          row << link_to(table_cell[:usage].split("/").last, table_cell[:usage], target: "_blank", class: "text-secondary underline", rel: "noopener")
          row
        end
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
