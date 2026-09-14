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

        taxonomies = create_taxonomies!
        taxonomies.each do |taxonomy|
          config_value(:accountability_results_per_taxonomy_count).times do
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
        config_value(:accountability_statuses_count).times do |i|
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

        config_value(:accountability_taxonomies_count).times do
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
        result = Decidim.traceability.perform_action!(
          "create",
          Decidim::Accountability::Result,
          admin_user,
          visibility: "all"
        ) do
          result = Decidim::Accountability::Result.new(
            component:,
            taxonomies: [taxonomy],
            title: Decidim::Faker::Localized.sentence(word_count: 2),
            description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
              Decidim::Faker::Localized.paragraph(sentence_count: 3)
            end,
            address: "#{::Faker::Address.street_address} #{::Faker::Address.zip} #{::Faker::Address.city}",
            latitude: ::Faker::Address.latitude,
            longitude: ::Faker::Address.longitude
          )
          result.save!(validate: false)
          result
        end

        Decidim::Comments::Seed.comments_for(result)

        config_value(:accountability_children_per_result_count).times do
          child_result = Decidim.traceability.perform_action!(
            "create",
            Decidim::Accountability::Result,
            admin_user,
            visibility: "all"
          ) do
            res = Decidim::Accountability::Result.new(
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
            )
            res.save!(validate: false)
            res
          end

          # rubocop:disable Rails/SkipsModelValidations
          child_result.milestones.insert_all(
            config_value(:accountability_milestones_per_result_count).times.map do |i|
              {
                entry_date: child_result.start_date + i.days,
                title: Decidim::Faker::Localized.sentence(word_count: 2),
                description: Decidim::Faker::Localized.paragraph(sentence_count: 1)
              }
            end
          )
          # rubocop:enable Rails/SkipsModelValidations

          Decidim::Comments::Seed.comments_for(child_result)
        end
      end
    end
  end
end
