# frozen_string_literal: true

Decidim.register_participatory_space(:conferences) do |participatory_space|
  participatory_space.icon = "media/images/decidim_conferences.svg"
  participatory_space.model_class_name = "Decidim::Conference"
  participatory_space.stylesheet = "decidim/conferences/conferences"

  participatory_space.participatory_spaces do |organization|
    Decidim::Conferences::OrganizationConferences.new(organization).query
  end

  participatory_space.permissions_class_name = "Decidim::Conferences::Permissions"
  participatory_space.data_portable_entities = [
    "Decidim::Conferences::ConferenceRegistration",
    "Decidim::Conferences::ConferenceInvite"
  ]

  participatory_space.query_type = "Decidim::Conferences::ConferenceType"

  participatory_space.register_resource(:conference) do |resource|
    resource.model_class_name = "Decidim::Conference"
    resource.card = "decidim/conferences/conference"
    resource.searchable = true
  end

  participatory_space.context(:public) do |context|
    context.engine = Decidim::Conferences::Engine
    context.layout = "layouts/decidim/conference"
    context.helper = "Decidim::Conferences::ConferenceHelper"
  end

  participatory_space.context(:admin) do |context|
    context.engine = Decidim::Conferences::AdminEngine
    context.layout = "layouts/decidim/admin/conference"
  end

  participatory_space.register_on_destroy_account do |user|
    Decidim::ConferenceUserRole.where(user: user).destroy_all
    Decidim::ConferenceSpeaker.where(user: user).destroy_all
  end

  participatory_space.seeds do
    organization = Decidim::Organization.first
    seeds_root = File.join(__dir__, "..", "..", "..", "db", "seeds")

    Decidim::ContentBlock.create(
      organization: organization,
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
        hashtag: "##{Faker::Lorem.word}",
        short_description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
          Decidim::Faker::Localized.sentence(word_count: 3)
        end,
        description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
          Decidim::Faker::Localized.paragraph(sentence_count: 3)
        end,
        organization: organization,
        hero_image: ActiveStorage::Blob.create_and_upload!(
          io: File.open(File.join(seeds_root, "city.jpeg")),
          filename: "hero_image.jpeg",
          content_type: "image/jpeg",
          metadata: nil
        ), # Keep after organization
        banner_image: ActiveStorage::Blob.create_and_upload!(
          io: File.open(File.join(seeds_root, "city2.jpeg")),
          filename: "banner_image.jpeg",
          content_type: "image/jpeg",
          metadata: nil
        ), # Keep after organization
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

        user = Decidim::User.find_or_initialize_by(email: email)
        user.update!(
          name: Faker::Name.name,
          nickname: Faker::Twitter.unique.screen_name,
          password: "decidim123456789",
          password_confirmation: "decidim123456789",
          organization: organization,
          confirmed_at: Time.current,
          locale: I18n.default_locale,
          tos_agreement: true
        )

        Decidim::ConferenceUserRole.find_or_create_by!(
          user: user,
          conference: conference,
          role: role
        )
      end

      attachment_collection = Decidim::AttachmentCollection.create!(
        name: Decidim::Faker::Localized.word,
        description: Decidim::Faker::Localized.sentence(word_count: 5),
        collection_for: conference
      )

      Decidim::Attachment.create!(
        title: Decidim::Faker::Localized.sentence(word_count: 2),
        description: Decidim::Faker::Localized.sentence(word_count: 5),
        attachment_collection: attachment_collection,
        attached_to: conference,
        content_type: "application/pdf",
        file: ActiveStorage::Blob.create_and_upload!(
          io: File.open(File.join(seeds_root, "Exampledocument.pdf")),
          filename: "Exampledocument.pdf",
          content_type: "application/pdf",
          metadata: nil
        ) # Keep after attached_to
      )

      Decidim::Attachment.create!(
        title: Decidim::Faker::Localized.sentence(word_count: 2),
        description: Decidim::Faker::Localized.sentence(word_count: 5),
        attached_to: conference,
        content_type: "image/jpeg",
        file: ActiveStorage::Blob.create_and_upload!(
          io: File.open(File.join(seeds_root, "city.jpeg")),
          filename: "city.jpeg",
          content_type: "image/jpeg",
          metadata: nil
        ) # Keep after attached_to
      )

      Decidim::Attachment.create!(
        title: Decidim::Faker::Localized.sentence(word_count: 2),
        description: Decidim::Faker::Localized.sentence(word_count: 5),
        attached_to: conference,
        content_type: "application/pdf",
        file: ActiveStorage::Blob.create_and_upload!(
          io: File.open(File.join(seeds_root, "Exampledocument.pdf")),
          filename: "Exampledocument.pdf",
          content_type: "application/pdf",
          metadata: nil
        ) # Keep after attached_to
      )

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
          full_name: Faker::Name.name,
          position: Decidim::Faker::Localized.word,
          affiliation: Decidim::Faker::Localized.sentence(word_count: 3),
          short_bio: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
            Decidim::Faker::Localized.paragraph(sentence_count: 3)
          end,
          twitter_handle: Faker::Twitter.unique.screen_name,
          personal_url: Faker::Internet.url,
          conference: conference
        )
      end

      Decidim::Conferences::Partner::TYPES.map do |type|
        4.times do
          Decidim::Conferences::Partner.create!(
            name: Faker::Name.name,
            weight: Faker::Number.between(from: 1, to: 10),
            link: Faker::Internet.url,
            partner_type: type,
            conference: conference,
            logo: ActiveStorage::Blob.create_and_upload!(
              io: File.open(File.join(seeds_root, "logo.png")),
              filename: "logo.png",
              content_type: "image/png",
              metadata: nil
            ) # Keep after conference
          )
        end
      end

      5.times do
        Decidim::Conferences::MediaLink.create!(
          title: Decidim::Faker::Localized.sentence(word_count: 2),
          link: Faker::Internet.url,
          date: Date.current,
          weight: Faker::Number.between(from: 1, to: 10),
          conference: conference
        )
      end

      5.times do
        Decidim::Conferences::RegistrationType.create!(
          title: Decidim::Faker::Localized.sentence(word_count: 2),
          description: Decidim::Faker::Localized.sentence(word_count: 5),
          weight: Faker::Number.between(from: 1, to: 10),
          price: Faker::Number.between(from: 1, to: 300),
          published_at: 2.weeks.ago,
          conference: conference
        )
      end

      Decidim.component_manifests.each do |manifest|
        manifest.seed!(conference.reload)
      end

      Decidim::ConferenceMeeting.where(component: conference.components).each do |conference_meeting|
        next unless Faker::Boolean.boolean(true_ratio: 0.5)

        conference.speakers.sample(3).each do |speaker|
          Decidim::ConferenceSpeakerConferenceMeeting.create!(
            conference_meeting: conference_meeting,
            conference_speaker: speaker
          )
        end
      end
    end
  end
end
