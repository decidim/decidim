# frozen_string_literal: true

require "decidim/components/namer"

Decidim.register_component(:meetings) do |component|
  component.engine = Decidim::Meetings::Engine
  component.admin_engine = Decidim::Meetings::AdminEngine
  component.icon = "decidim/meetings/icon.svg"
  component.permissions_class_name = "Decidim::Meetings::Permissions"

  component.query_type = "Decidim::Meetings::MeetingsType"
  component.data_portable_entities = ["Decidim::Meetings::Registration"]

  component.on(:before_destroy) do |instance|
    raise StandardError, "Can't remove this component" if Decidim::Meetings::Meeting.where(component: instance).any?
  end

  component.register_resource(:meeting) do |resource|
    resource.model_class_name = "Decidim::Meetings::Meeting"
    resource.template = "decidim/meetings/meetings/linked_meetings"
    resource.card = "decidim/meetings/meeting"
    resource.actions = %w(join)
  end

  component.register_stat :meetings_count, primary: true, priority: Decidim::StatsRegistry::MEDIUM_PRIORITY do |components, start_at, end_at|
    meetings = Decidim::Meetings::Meeting.where(component: components)
    meetings = meetings.where("created_at >= ?", start_at) if start_at.present?
    meetings = meetings.where("created_at <= ?", end_at) if end_at.present?
    meetings.count
  end

  component.actions = %w(join)

  component.settings(:global) do |settings|
    settings.attribute :announcement, type: :text, translated: true, editor: true
    settings.attribute :default_registration_terms, type: :text, translated: true, editor: true
    settings.attribute :comments_enabled, type: :boolean, default: true
    settings.attribute :resources_permissions_enabled, type: :boolean, default: true
  end

  component.settings(:step) do |settings|
    settings.attribute :announcement, type: :text, translated: true, editor: true
    settings.attribute :comments_blocked, type: :boolean, default: false
  end

  component.seeds do |participatory_space|
    component = Decidim::Component.create!(
      name: Decidim::Components::Namer.new(participatory_space.organization.available_locales, :meetings).i18n_name,
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

    2.times do
      meeting = Decidim::Meetings::Meeting.create!(
        component: component,
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
        end,
        services: [
          { title: Decidim::Faker::Localized.sentence(2), description: Decidim::Faker::Localized.sentence(5) },
          { title: Decidim::Faker::Localized.sentence(2), description: Decidim::Faker::Localized.sentence(5) }
        ]
      )

      2.times do |n|
        email = "meeting-registered-user-#{meeting.id}-#{n}@example.org"
        name = "#{Faker::Name.name} #{meeting.id} #{n}"
        user = Decidim::User.find_or_initialize_by(email: email)

        user.update!(
          password: "password1234",
          password_confirmation: "password1234",
          name: name,
          nickname: Faker::Twitter.unique.screen_name,
          organization: component.organization,
          tos_agreement: "1",
          confirmed_at: Time.current,
          personal_url: Faker::Internet.url,
          about: Faker::Lorem.paragraph(2)
        )

        Decidim::Meetings::Registration.create!(
          meeting: meeting,
          user: user
        )
      end

      attachment_collection = Decidim::AttachmentCollection.create!(
        name: Decidim::Faker::Localized.word,
        description: Decidim::Faker::Localized.sentence(5),
        collection_for: meeting
      )

      Decidim::Attachment.create!(
        title: Decidim::Faker::Localized.sentence(2),
        description: Decidim::Faker::Localized.sentence(5),
        file: File.new(File.join(__dir__, "seeds", "Exampledocument.pdf")),
        attachment_collection: attachment_collection,
        attached_to: meeting
      )
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

Decidim.register_global_engine(
  :meetings_directory,
  Decidim::Meetings::DirectoryEngine,
  at: "/meetings"
)
