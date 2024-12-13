# frozen_string_literal: true

module Decidim
  module Design
    module AuthorHelper
      def author_sections
        [
          {
            title: t("decidim.design.helpers.context"),
            contents: [
              {
                type: :text,
                values: [
                  t("decidim.design.helpers.context_description"),
                  t("decidim.design.helpers.context_description_2")
                ]
              }
            ]
          },
          {
            title: t("decidim.design.helpers.variations"),
            contents: [
              {
                type: :text,
                values: [t("decidim.design.helpers.variations_description")]
              },
              {
                values: section_subtitle(title: t("decidim.design.helpers.default"))
              },
              {
                values: cell("decidim/author", user_item, demo: true)
              },
              {
                type: :text,
                values: [t("decidim.design.helpers.default_description")]
              },
              {
                values: section_subtitle(title: t("decidim.design.helpers.compact"))
              },
              {
                values: cell("decidim/author", user_item, from: authored_item, context_actions: [:date], layout: :compact, demo: true)
              },
              {
                type: :text,
                values: [t("decidim.design.helpers.compact_description")]
              },
              {
                values: section_subtitle(title: t("decidim.design.helpers.avatar"))
              },
              {
                values: cell("decidim/author", user_item, layout: :avatar, demo: true)
              },
              {
                type: :text,
                values: [t("decidim.design.helpers.avatar_description")]
              }
            ]
          },
          {
            title: t("decidim.design.helpers.source_code"),
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
