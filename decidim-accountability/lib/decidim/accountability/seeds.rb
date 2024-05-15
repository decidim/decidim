# frozen_string_literal: true

require "decidim/components/namer"

module Decidim
  module Accountability
    class Seeds
      attr_reader :participatory_space

      def initialize(participatory_space:)
        @participatory_space = participatory_space
      end

      def call
        admin_user = Decidim::User.find_by(
          organization: participatory_space.organization,
          email: "admin@example.org"
        )

        params = {
          name: Decidim::Components::Namer.new(participatory_space.organization.available_locales, :accountability).i18n_name,
          manifest_name: :accountability,
          published_at: Time.current,
          participatory_space:,
          settings: {
            intro: Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(word_count: 4) },
            categories_label: Decidim::Faker::Localized.word,
            subcategories_label: Decidim::Faker::Localized.word,
            heading_parent_level_results: Decidim::Faker::Localized.word,
            heading_leaf_level_results: Decidim::Faker::Localized.word,
            scopes_enabled: true,
            scope_id: participatory_space.scope&.id
          }
        }

        component = Decidim.traceability.perform_action!("publish", Decidim::Component, admin_user, visibility: "all") do
          Decidim::Component.create!(params)
        end

        5.times do |i|
          Decidim::Accountability::Status.create!(
            component:,
            name: Decidim::Faker::Localized.word,
            key: "status_#{i}"
          )
        end

        3.times do
          parent_category = participatory_space.categories.sample
          categories = [parent_category]

          2.times do
            categories << Decidim::Category.create!(
              name: Decidim::Faker::Localized.sentence(word_count: 5),
              description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
                Decidim::Faker::Localized.paragraph(sentence_count: 3)
              end,
              parent: parent_category,
              participatory_space:
            )
          end

          categories.each do |category|
            result = Decidim.traceability.create!(
              Decidim::Accountability::Result,
              admin_user,
              {
                component:,
                scope: participatory_space.organization.scopes.sample,
                category:,
                title: Decidim::Faker::Localized.sentence(word_count: 2),
                description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
                  Decidim::Faker::Localized.paragraph(sentence_count: 3)
                end
              },
              visibility: "all"
            )

            Decidim::Comments::Seed.comments_for(result)

            3.times do
              child_result = Decidim.traceability.create!(
                Decidim::Accountability::Result,
                admin_user,
                {
                  component:,
                  parent: result,
                  start_date: Time.zone.today,
                  end_date: Time.zone.today + 10,
                  status: Decidim::Accountability::Status.all.sample,
                  progress: rand(1..100),
                  title: Decidim::Faker::Localized.sentence(word_count: 2),
                  description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
                    Decidim::Faker::Localized.paragraph(sentence_count: 3)
                  end
                },
                visibility: "all"
              )

              rand(0..5).times do |i|
                child_result.timeline_entries.create!(
                  entry_date: child_result.start_date + i.days,
                  title: Decidim::Faker::Localized.sentence(word_count: 2),
                  description: Decidim::Faker::Localized.paragraph(sentence_count: 1)
                )
              end

              Decidim::Comments::Seed.comments_for(child_result)
            end
          end
        end
      end
    end
  end
end
