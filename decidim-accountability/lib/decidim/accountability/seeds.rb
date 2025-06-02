# frozen_string_literal: true

require "decidim/components/namer"

module Decidim
  module Accountability
    class Seeds < Decidim::Seeds
      attr_reader :participatory_space

      def initialize(participatory_space:)
        @participatory_space = participatory_space
      end

      def call
        component = create_component!

        create_statuses!(component:)

        number_of_records.times do
          taxonomies = create_taxonomies!

          taxonomies.each do |taxonomy|
            create_result!(component:, taxonomy:)
          end
        end
      end

      def create_component!
        params = {
          name: Decidim::Components::Namer.new(organization.available_locales, :accountability).i18n_name,
          manifest_name: :accountability,
          published_at: Time.current,
          participatory_space:,
          settings: {
            intro: Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(word_count: 4) },
            taxonomy_filters: create_filters!.pluck(:id)
          }
        }

        Decidim.traceability.perform_action!("publish", Decidim::Component, admin_user, visibility: "all") do
          Decidim::Component.create!(params)
        end
      end

      def create_statuses!(component:)
        5.times do |i|
          Decidim::Accountability::Status.create!(
            component:,
            name: Decidim::Faker::Localized.word,
            key: "status_#{i}"
          )
        end
      end

      def root_taxonomy
        @root_taxonomy ||= organization.taxonomies.roots.find_by("name->>'#{I18n.locale}'= ?",
                                                                 "Categories") || organization.taxonomies.roots.sample
      end

      def create_taxonomies!
        parent_taxonomy = root_taxonomy.children.sample || create_taxonomy!(name: ::Faker::Lorem.sentence(word_count: 5), parent: root_taxonomy)
        taxonomies = [parent_taxonomy]

        2.times do
          taxonomies << if parent_taxonomy.children.count > 1
                          parent_taxonomy.children.sample
                        else
                          create_taxonomy!(name: ::Faker::Lorem.sentence(word_count: 5), parent: parent_taxonomy)
                        end
        end

        taxonomies
      end

      def create_filters!
        root_taxonomy.taxonomy_filters || [create_taxonomy_filter!(root_taxonomy:, taxonomies: root_taxonomy.all_children)]
      end

      def create_result!(component:, taxonomy:)
        result = Decidim.traceability.create!(
          Decidim::Accountability::Result,
          admin_user,
          {
            component:,
            taxonomies: [taxonomy],
            title: Decidim::Faker::Localized.sentence(word_count: 2),
            description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
              Decidim::Faker::Localized.paragraph(sentence_count: 3)
            end,
            address: "#{::Faker::Address.street_address} #{::Faker::Address.zip} #{::Faker::Address.city}",
            latitude: ::Faker::Address.latitude,
            longitude: ::Faker::Address.longitude
          },
          visibility: "all"
        )

        Decidim::Comments::Seed.comments_for(result)

        number_of_records.times do
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

          number_of_records.times do |i|
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
