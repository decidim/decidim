# frozen_string_literal: true

require "decidim/seeds"

module Decidim
  module Conferences
    class Seeds < Decidim::Seeds
      def call
        create_content_block!

        number_of_records.times do |_n|
          conference = create_conference!

          create_conference_user_roles!(conference:)

          create_attachments!(attached_to: conference)

          number_of_records.times do
            create_conference_speaker!(conference:)
          end

          Decidim::Conferences::Partner::TYPES.map do |type|
            number_of_records.times do
              create_conference_partner!(conference:, type:)
            end
          end

          number_of_records.times do
            create_conference_media_link!(conference:)
          end

          number_of_records.times do
            create_conference_registration_type!(conference:)
          end

          Decidim.component_manifests.each do |manifest|
            manifest.seed!(conference.reload)
          end

          create_conference_meeting!(conference:)
        end
      end

      def create_content_block!
        Decidim::ContentBlock.create(
          organization:,
          weight: 33,
          scope_name: :homepage,
          manifest_name: :highlighted_conferences,
          published_at: Time.current
        )
      end

      def create_conference!
        params = {
          title: Decidim::Faker::Localized.sentence(word_count: 5),
          slogan: Decidim::Faker::Localized.sentence(word_count: 2),
          slug: Decidim::Faker::Internet.unique.slug(words: nil, glue: "-"),
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
          objectives: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
            Decidim::Faker::Localized.paragraph(sentence_count: 3)
          end,
          start_date: Time.current,
          end_date: 2.months.from_now.at_midnight,
          registrations_enabled: [true, false].sample,
          available_slots: (10..50).step(10).to_a.sample,
          registration_terms: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
            Decidim::Faker::Localized.paragraph(sentence_count: 3)
          end
        }

        conference = Decidim.traceability.perform_action!(
          "publish",
          Decidim::Conference,
          organization.users.first,
          visibility: "all"
        ) do
          Decidim::Conference.create!(params)
        end
        conference.add_to_index_as_search_resource

        conference
      end

      def create_conference_user_roles!(conference:)
        # Create users with specific roles
        Decidim::ConferenceUserRole::ROLES.each do |role|
          email = "conference_#{conference.id}_#{role}@example.org"
          user = find_or_initialize_user_by(email:)

          Decidim::ConferenceUserRole.find_or_create_by!(
            user:,
            conference:,
            role:
          )
        end
      end

      def create_conference_speaker!(conference:)
        Decidim::ConferenceSpeaker.create!(
          user: conference.organization.users.sample,
          full_name: ::Faker::Name.name,
          position: Decidim::Faker::Localized.word,
          affiliation: Decidim::Faker::Localized.sentence(word_count: 3),
          short_bio: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
            Decidim::Faker::Localized.paragraph(sentence_count: 3)
          end,
          twitter_handle: ::Faker::Twitter.unique.screen_name,
          personal_url: ::Faker::Internet.url,
          published_at: Time.current,
          conference:
        )
      end

      def create_conference_partner!(conference:, type:)
        Decidim::Conferences::Partner.create!(
          name: ::Faker::Name.name,
          weight: ::Faker::Number.between(from: 1, to: 10),
          link: ::Faker::Internet.url,
          partner_type: type,
          conference:,
          logo: create_blob!(seeds_file: "logo.png", filename: "logo.png", content_type: "image/png")
        )
      end

      def create_conference_media_link!(conference:)
        Decidim::Conferences::MediaLink.create!(
          title: Decidim::Faker::Localized.sentence(word_count: 2),
          link: ::Faker::Internet.url,
          date: Date.current,
          weight: ::Faker::Number.between(from: 1, to: 10),
          conference:
        )
      end

      def create_conference_registration_type!(conference:)
        Decidim::Conferences::RegistrationType.create!(
          title: Decidim::Faker::Localized.sentence(word_count: 2),
          description: Decidim::Faker::Localized.sentence(word_count: 5),
          weight: ::Faker::Number.between(from: 1, to: 10),
          price: ::Faker::Number.between(from: 1, to: 300),
          published_at: 2.weeks.ago,
          conference:
        )
      end

      def create_conference_meeting!(conference:)
        Decidim::ConferenceMeeting.where(component: conference.components).each do |conference_meeting|
          next unless ::Faker::Boolean.boolean(true_ratio: 0.5)

          conference.speakers.sample(3).each do |speaker|
            Decidim::ConferenceSpeakerConferenceMeeting.create!(
              conference_meeting:,
              conference_speaker: speaker
            )
          end
        end
      end
    end
  end
end
