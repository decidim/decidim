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
    resource.searchable = true
  end

  component.register_stat :meetings_count, primary: true, priority: Decidim::StatsRegistry::MEDIUM_PRIORITY do |components, start_at, end_at|
    meetings = Decidim::Meetings::FilteredMeetings.for(components, start_at, end_at)
    meetings.count
  end

  component.register_stat :followers_count, tag: :followers, priority: Decidim::StatsRegistry::LOW_PRIORITY do |components, start_at, end_at|
    meetings_ids = Decidim::Meetings::FilteredMeetings.for(components, start_at, end_at).pluck(:id)
    Decidim::Follow.where(decidim_followable_type: "Decidim::Meetings::Meeting", decidim_followable_id: meetings_ids).count
  end

  component.exports :meetings do |exports|
    exports.collection do |component_instance|
      Decidim::Meetings::Meeting
        .not_hidden
        .visible
        .where(component: component_instance)
        .includes(component: { participatory_space: :organization })
    end

    exports.include_in_open_data = true

    exports.serializer Decidim::Meetings::MeetingSerializer
  end

  component.actions = %w(join)

  component.settings(:global) do |settings|
    settings.attribute :announcement, type: :text, translated: true, editor: true
    settings.attribute :default_registration_terms, type: :text, translated: true, editor: true
    settings.attribute :comments_enabled, type: :boolean, default: true
    settings.attribute :resources_permissions_enabled, type: :boolean, default: true
    settings.attribute :enable_pads_creation, type: :boolean, default: false
  end

  component.settings(:step) do |settings|
    settings.attribute :announcement, type: :text, translated: true, editor: true
    settings.attribute :comments_blocked, type: :boolean, default: false
  end

  component.seeds do |participatory_space|
    admin_user = Decidim::User.find_by(
      organization: participatory_space.organization,
      email: "admin@example.org"
    )

    params = {
      name: Decidim::Components::Namer.new(participatory_space.organization.available_locales, :meetings).i18n_name,
      published_at: Time.current,
      manifest_name: :meetings,
      participatory_space: participatory_space
    }

    component = Decidim.traceability.perform_action!(
      "publish",
      Decidim::Component,
      admin_user,
      visibility: "all"
    ) do
      Decidim::Component.create!(params)
    end

    if participatory_space.scope
      scopes = participatory_space.scope.descendants
      global = participatory_space.scope
    else
      scopes = participatory_space.organization.scopes
      global = nil
    end

    2.times do
      params = {
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
        organizer: participatory_space.organization,
        registration_terms: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
          Decidim::Faker::Localized.paragraph(3)
        end,
        services: [
          { title: Decidim::Faker::Localized.sentence(2), description: Decidim::Faker::Localized.sentence(5) },
          { title: Decidim::Faker::Localized.sentence(2), description: Decidim::Faker::Localized.sentence(5) }
        ]
      }

      meeting = Decidim.traceability.create!(
        Decidim::Meetings::Meeting,
        admin_user,
        params,
        visibility: "all"
      )

      Decidim::Forms::Questionnaire.create!(
        title: Decidim::Faker::Localized.paragraph,
        description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
          Decidim::Faker::Localized.paragraph(3)
        end,
        tos: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
          Decidim::Faker::Localized.paragraph(2)
        end,
        questionnaire_for: meeting
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

    organizers = [
      Decidim::UserGroup.where(decidim_organization_id: participatory_space.decidim_organization_id).verified.sample,
      Decidim::User.where(decidim_organization_id: participatory_space.decidim_organization_id).all.sample
    ]
    2.times do |i|
      params = {
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
        organizer_id: organizers[i].id,
        organizer_type: organizers[i].type
      }

      Decidim.traceability.create!(
        Decidim::Meetings::Meeting,
        organizers[0],
        params,
        visibility: "all"
      )
    end
  end
end

Decidim.register_global_engine(
  :meetings_directory,
  Decidim::Meetings::DirectoryEngine,
  at: "/meetings"
)
