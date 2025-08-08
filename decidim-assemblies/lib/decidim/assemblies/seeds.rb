# frozen_string_literal: true

require "decidim/seeds"

module Decidim
  module Assemblies
    class Seeds < Decidim::Seeds
      def call
        create_content_block!

        taxonomy = create_taxonomy!(name: "Assembly Types", parent: nil)
        number_of_records.times do
          create_taxonomy!(name: ::Faker::Lorem.word, parent: taxonomy)
        end
        # filters for assemblies only
        create_taxonomy_filter!(root_taxonomy: taxonomy,
                                taxonomies: taxonomy.all_children,
                                participatory_space_manifests: [:assemblies])

        number_of_records.times do |_n|
          assembly = create_assembly!

          create_assembly_user_roles!(assembly:)

          child = create_assembly!(parent: assembly)

          [assembly, child].each do |current_assembly|
            current_assembly.add_to_index_as_search_resource

            create_attachments!(attached_to: current_assembly)

            seed_components_manifests!(participatory_space: current_assembly)

            Decidim::ContentBlocksCreator.new(current_assembly).create_default!
          end
        end
      end

      def create_content_block!
        Decidim::ContentBlock.create(
          organization:,
          weight: 32,
          scope_name: :homepage,
          manifest_name: :highlighted_assemblies,
          published_at: Time.current
        )
      end

      def create_assembly!(parent: nil)
        n = rand(2)
        params = {
          title: Decidim::Faker::Localized.sentence(word_count: 5),
          slug: Decidim::Faker::Internet.unique.slug(words: nil, glue: "-"),
          subtitle: Decidim::Faker::Localized.sentence(word_count: 2),
          short_description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
            Decidim::Faker::Localized.sentence(word_count: 3)
          end,
          description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
            Decidim::Faker::Localized.paragraph(sentence_count: 3)
          end,
          organization:,
          hero_image: ::Faker::Boolean.boolean(true_ratio: 0.5) ? hero_image : nil, # Keep after organization
          banner_image: ::Faker::Boolean.boolean(true_ratio: 0.5) ? banner_image : nil, # Keep after organization
          promoted: true,
          published_at: 2.weeks.ago,
          meta_scope: Decidim::Faker::Localized.word,
          developer_group: Decidim::Faker::Localized.sentence(word_count: 1),
          local_area: Decidim::Faker::Localized.sentence(word_count: 2),
          target: Decidim::Faker::Localized.sentence(word_count: 3),
          participatory_scope: Decidim::Faker::Localized.sentence(word_count: 1),
          participatory_structure: Decidim::Faker::Localized.sentence(word_count: 2),
          scope: n.positive? ? Decidim::Scope.all.sample : nil,
          purpose_of_action: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
            Decidim::Faker::Localized.paragraph(sentence_count: 3)
          end,
          composition: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
            Decidim::Faker::Localized.paragraph(sentence_count: 3)
          end,
          creation_date: 1.day.from_now,
          created_by: "others",
          created_by_other: Decidim::Faker::Localized.word,
          duration: 2.days.from_now,
          included_at: 5.days.from_now,
          closing_date: 5.days.from_now,
          closing_date_reason: Decidim::Faker::Localized.sentence(word_count: 3),
          internal_organisation: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
            Decidim::Faker::Localized.paragraph(sentence_count: 3)
          end,
          is_transparent: true,
          special_features: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
            Decidim::Faker::Localized.paragraph(sentence_count: 3)
          end,
          twitter_handler: ::Faker::Lorem.word,
          facebook_handler: ::Faker::Lorem.word,
          instagram_handler: ::Faker::Lorem.word,
          youtube_handler: ::Faker::Lorem.word,
          github_handler: ::Faker::Lorem.word,
          parent:
        }

        Decidim.traceability.perform_action!(
          "publish",
          Decidim::Assembly,
          organization.users.first,
          visibility: "all"
        ) do
          Decidim::Assembly.create!(params)
        end
      end

      def create_assembly_user_roles!(assembly:)
        # Create users with specific roles
        Decidim::AssemblyUserRole::ROLES.each do |role|
          email = "assembly_#{assembly.id}_#{role}@example.org"
          user = find_or_initialize_user_by(email:)

          Decidim::AssemblyUserRole.find_or_create_by!(
            user:,
            assembly:,
            role:
          )
        end
      end
    end
  end
end
