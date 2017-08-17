# frozen_string_literal: true

require "decidim/features/namer"

Decidim.register_feature(:meetings) do |feature|
  feature.engine = Decidim::Meetings::Engine
  feature.admin_engine = Decidim::Meetings::AdminEngine
  feature.icon = "decidim/meetings/icon.svg"

  feature.on(:before_destroy) do |instance|
    raise StandardError, "Can't remove this feature" if Decidim::Meetings::Meeting.where(feature: instance).any?
  end

  feature.register_resource do |resource|
    resource.model_class_name = "Decidim::Meetings::Meeting"
    resource.template = "decidim/meetings/meetings/linked_meetings"
  end

  feature.register_stat :meetings_count, primary: true, priority: Decidim::StatsRegistry::MEDIUM_PRIORITY do |features, start_at, end_at|
    meetings = Decidim::Meetings::Meeting.where(feature: features)
    meetings = meetings.where("created_at >= ?", start_at) if start_at.present?
    meetings = meetings.where("created_at <= ?", end_at) if end_at.present?
    meetings.count
  end

  feature.actions = %w(join)

  feature.settings(:global) do |settings|
    settings.attribute :announcement, type: :text, translated: true, editor: true
  end

  feature.settings(:step) do |settings|
    settings.attribute :announcement, type: :text, translated: true, editor: true
  end

  feature.seeds do |participatory_space|
    feature = Decidim::Feature.create!(
      name: Decidim::Features::Namer.new(participatory_space.organization.available_locales, :meetings).i18n_name,
      published_at: Time.current,
      manifest_name: :meetings,
      participatory_space: participatory_space
    )

    if participatory_space.scope
      scopes = participatory_space.scope.descendants
      global = participatory_space.scope
    else
      scopes = participatory_space.organization.scopes
      global = nil
    end

    3.times do
      meeting = Decidim::Meetings::Meeting.create!(
        feature: feature,
        scope: Faker::Boolean.boolean(0.5) ? global : scopes.sample,
        category: participatory_space.categories.sample,
        title: Decidim::Faker::Localized.sentence(2),
        description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
          Decidim::Faker::Localized.paragraph(3)
        end,
        location: Decidim::Faker::Localized.sentence,
        location_hints: Decidim::Faker::Localized.sentence,
        start_time: 3.weeks.from_now,
        end_time: 3.weeks.from_now + 4.hours,
        address: "#{Faker::Address.street_address} #{Faker::Address.zip} #{Faker::Address.city}",
        latitude: Faker::Address.latitude,
        longitude: Faker::Address.longitude,
        registrations_enabled: [true, false].sample,
        available_slots: (10..50).step(10).to_a.sample,
        registration_terms: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
          Decidim::Faker::Localized.paragraph(3)
        end
      )

      10.times do |n|
        email = "meeting-registered-user-#{meeting.id}-#{n}@example.org"
        name = "#{Faker::Name.name} #{meeting.id} #{n}"
        user = Decidim::User.find_or_initialize_by(email: email)

        user.update!(
          password: "password1234",
          password_confirmation: "password1234",
          name: name,
          organization: feature.organization,
          tos_agreement: "1",
          confirmed_at: Time.current,
          comments_notifications: true,
          replies_notifications: true
        )

        Decidim::Meetings::Registration.create!(
          meeting: meeting,
          user: user
        )
      end

      Decidim::Attachment.create!(
        title: Decidim::Faker::Localized.sentence(2),
        description: Decidim::Faker::Localized.sentence(5),
        file: File.new(File.join(__dir__, "seeds", "city.jpeg")),
        attached_to: meeting
      )
      Decidim::Attachment.create!(
        title: Decidim::Faker::Localized.sentence(2),
        description: Decidim::Faker::Localized.sentence(5),
        file: File.new(File.join(__dir__, "seeds", "Exampledocument.pdf")),
        attached_to: meeting
      )
    end
  end
end
