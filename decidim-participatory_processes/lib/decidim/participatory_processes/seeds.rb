# frozen_string_literal: true

require "faker"
require "decidim/seeds"

module Decidim
  module ParticipatoryProcesses
    class Seeds < Decidim::Seeds
      def call
        Decidim::ContentBlock.create(
          organization:,
          weight: 31,
          scope_name: :homepage,
          manifest_name: :highlighted_processes,
          published_at: Time.current
        )

        process_groups = []
        2.times do
          process_groups << Decidim::ParticipatoryProcessGroup.create!(
            title: Decidim::Faker::Localized.sentence(word_count: 3),
            description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
              Decidim::Faker::Localized.paragraph(sentence_count: 3)
            end,
            hashtag: ::Faker::Internet.slug,
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

        process_groups.each do |process_group|
          Decidim::ContentBlocksCreator.new(process_group).create_default!
        end

        process_types = []
        2.times do
          process_types << Decidim::ParticipatoryProcessType.create!(
            title: Decidim::Faker::Localized.word,
            organization:
          )
        end

        2.times do |n|
          params = {
            title: Decidim::Faker::Localized.sentence(word_count: 5),
            slug: Decidim::Faker::Internet.unique.slug(words: nil, glue: "-"),
            subtitle: Decidim::Faker::Localized.sentence(word_count: 2),
            hashtag: "##{::Faker::Lorem.word}",
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
            start_date: Date.current,
            end_date: 2.months.from_now,
            participatory_process_group: process_groups.sample,
            participatory_process_type: process_types.sample,
            scope: n.positive? ? nil : Decidim::Scope.reorder(Arel.sql("RANDOM()")).first
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

          # Create users with specific roles
          Decidim::ParticipatoryProcessUserRole::ROLES.each do |role|
            email = "participatory_process_#{process.id}_#{role}@example.org"

            user = Decidim::User.find_or_initialize_by(email:)
            user.update!(
              name: ::Faker::Name.name,
              nickname: ::Faker::Twitter.unique.screen_name,
              password: "decidim123456789",
              organization:,
              confirmed_at: Time.current,
              locale: I18n.default_locale,
              tos_agreement: true
            )

            Decidim::ParticipatoryProcessUserRole.find_or_create_by!(
              user:,
              participatory_process: process,
              role:
            )

            Decidim::ContentBlocksCreator.new(process).create_default!
          end

          attachment_collection = create_attachment_collection(collection_for: process)
          create_attachment(attached_to: process, filename: "Exampledocument.pdf", attachment_collection:)
          create_attachment(attached_to: process, filename: "city.jpeg")
          create_attachment(attached_to: process, filename: "Exampledocument.pdf")

          2.times do
            Decidim::Category.create!(
              name: Decidim::Faker::Localized.sentence(word_count: 5),
              description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
                Decidim::Faker::Localized.paragraph(sentence_count: 3)
              end,
              participatory_space: process
            )
          end

          Decidim.component_manifests.each do |manifest|
            manifest.seed!(process.reload)
          end
        end
      end
    end
  end
end
