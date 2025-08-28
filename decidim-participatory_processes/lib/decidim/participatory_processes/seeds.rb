# frozen_string_literal: true

require "faker"
require "decidim/seeds"

module Decidim
  module ParticipatoryProcesses
    class Seeds < Decidim::Seeds
      def call
        create_content_block!

        process_groups = []
        number_of_records.times do
          process_groups << create_process_group!
        end

        process_groups.each do |process_group|
          Decidim::ContentBlocksCreator.new(process_group).create_default!
        end

        taxonomy = create_taxonomy!(name: "Process Types", parent: nil)
        number_of_records.times do
          create_taxonomy!(name: ::Faker::Lorem.word, parent: taxonomy)
        end
        # filters for processes only
        create_taxonomy_filter!(root_taxonomy: taxonomy,
                                taxonomies: taxonomy.all_children,
                                participatory_space_manifests: [:participatory_processes])

        number_of_records.times do |_n|
          process = create_process!(process_group: process_groups.sample)

          create_follow!(Decidim::User.where(organization:, admin: true).first, process)
          create_follow!(Decidim::User.where(organization:, admin: false).first, process)

          create_process_step!(process:)

          create_process_user_roles!(process:)

          Decidim::ContentBlocksCreator.new(process).create_default!

          create_attachments!(attached_to: process)

          seed_components_manifests!(participatory_space: process)
        end
      end

      def create_content_block!
        Decidim::ContentBlock.create(
          organization:,
          weight: 31,
          scope_name: :homepage,
          manifest_name: :highlighted_processes,
          published_at: Time.current
        )
      end

      def create_process_group!
        Decidim::ParticipatoryProcessGroup.create!(
          title: Decidim::Faker::Localized.sentence(word_count: 3),
          description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
            Decidim::Faker::Localized.paragraph(sentence_count: 3)
          end,
          group_url: ::Faker::Internet.url,
          organization:,
          hero_image: ::Faker::Boolean.boolean(true_ratio: 0.5) ? hero_image : nil, # Keep after organization
          developer_group: Decidim::Faker::Localized.sentence(word_count: 1),
          local_area: Decidim::Faker::Localized.sentence(word_count: 2),
          meta_scope: Decidim::Faker::Localized.word,
          target: Decidim::Faker::Localized.sentence(word_count: 3),
          participatory_scope: Decidim::Faker::Localized.sentence(word_count: 1),
          participatory_structure: Decidim::Faker::Localized.sentence(word_count: 2)
        )
      end

      def create_process!(process_group: nil)
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
          promoted: true,
          published_at: 2.weeks.ago,
          meta_scope: Decidim::Faker::Localized.word,
          developer_group: Decidim::Faker::Localized.sentence(word_count: 1),
          local_area: Decidim::Faker::Localized.sentence(word_count: 2),
          target: Decidim::Faker::Localized.sentence(word_count: 3),
          participatory_scope: Decidim::Faker::Localized.sentence(word_count: 1),
          participatory_structure: Decidim::Faker::Localized.sentence(word_count: 2),
          start_date: Date.current,
          end_date: 2.months.from_now,
          participatory_process_group: process_group,
          scope: n.positive? ? nil : Decidim::Scope.all.sample
        }

        process = Decidim.traceability.perform_action!(
          "publish",
          Decidim::ParticipatoryProcess,
          organization.users.first,
          visibility: "all"
        ) do
          Decidim::ParticipatoryProcess.create!(params)
        end
        process.add_to_index_as_search_resource

        process
      end

      def create_process_step!(process:)
        Decidim::ParticipatoryProcessStep.find_or_initialize_by(
          participatory_process: process,
          active: true
        ).update!(
          title: Decidim::Faker::Localized.sentence(word_count: 1, supplemental: false, random_words_to_add: 2),
          description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
            Decidim::Faker::Localized.paragraph(sentence_count: 3)
          end,
          start_date: 1.month.ago,
          end_date: 2.months.from_now
        )
      end

      def create_process_user_roles!(process:)
        # Create users with specific roles
        Decidim::ParticipatoryProcessUserRole::ROLES.each do |role|
          email = "participatory_process_#{process.id}_#{role}@example.org"
          user = find_or_initialize_user_by(email:)

          Decidim::ParticipatoryProcessUserRole.find_or_create_by!(
            user:,
            participatory_process: process,
            role:
          )
        end
      end
    end
  end
end
