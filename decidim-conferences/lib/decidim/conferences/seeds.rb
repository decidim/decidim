# frozen_string_literal: true

require "decidim/seeds"

module Decidim
  module Conferences
    class Seeds < Decidim::Seeds
      def call
        organization = Decidim::Organization.first
        seeds_root = File.join(__dir__, "..", "..", "..", "db", "seeds")

        Decidim::ContentBlock.create(
          organization:,
          weight: 33,
          scope_name: :homepage,
          manifest_name: :highlighted_conferences,
          published_at: Time.current
        )

        2.times do |_n|
          conference = Decidim::Conference.create!(
            title: Decidim::Faker::Localized.sentence(word_count: 5),
            slogan: Decidim::Faker::Localized.sentence(word_count: 2),
            slug: Decidim::Faker::Internet.unique.slug(words: nil, glue: "-"),
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
          )
          conference.add_to_index_as_search_resource

          # Create users with specific roles
          Decidim::ConferenceUserRole::ROLES.each do |role|
            email = "conference_#{conference.id}_#{role}@example.org"

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

            Decidim::ConferenceUserRole.find_or_create_by!(
              user:,
              conference:,
              role:
            )
          end

          attachment_collection = create_attachment_collection(collection_for: conference)
          create_attachment(attached_to: conference, filename: "Exampledocument.pdf", attachment_collection:)
          create_attachment(attached_to: conference, filename: "city.jpeg")
          create_attachment(attached_to: conference, filename: "Exampledocument.pdf")

          2.times do
            Decidim::Category.create!(
              name: Decidim::Faker::Localized.sentence(word_count: 5),
              description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
                Decidim::Faker::Localized.paragraph(sentence_count: 3)
              end,
              participatory_space: conference
            )
          end

          5.times do
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
              conference:
            )
          end

          Decidim::Conferences::Partner::TYPES.map do |type|
            4.times do
              Decidim::Conferences::Partner.create!(
                name: ::Faker::Name.name,
                weight: ::Faker::Number.between(from: 1, to: 10),
                link: ::Faker::Internet.url,
                partner_type: type,
                conference:,
                logo: create_image!(seeds_file: "logo.png", filename: "logo.png")
              )
            end
          end

          5.times do
            Decidim::Conferences::MediaLink.create!(
              title: Decidim::Faker::Localized.sentence(word_count: 2),
              link: ::Faker::Internet.url,
              date: Date.current,
              weight: ::Faker::Number.between(from: 1, to: 10),
              conference:
            )
          end

          5.times do
            Decidim::Conferences::RegistrationType.create!(
              title: Decidim::Faker::Localized.sentence(word_count: 2),
              description: Decidim::Faker::Localized.sentence(word_count: 5),
              weight: ::Faker::Number.between(from: 1, to: 10),
              price: ::Faker::Number.between(from: 1, to: 300),
              published_at: 2.weeks.ago,
              conference:
            )
          end

          Decidim.component_manifests.each do |manifest|
            manifest.seed!(conference.reload)
          end

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
end
