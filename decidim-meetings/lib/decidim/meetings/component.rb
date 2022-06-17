# frozen_string_literal: true

require "decidim/components/namer"

Decidim.register_component(:meetings) do |component|
  component.engine = Decidim::Meetings::Engine
  component.admin_engine = Decidim::Meetings::AdminEngine
  component.icon = "media/images/decidim_meetings.svg"
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
    resource.reported_content_cell = "decidim/meetings/reported_content"
    resource.actions = %w(join comment)
    resource.searchable = true
  end

  component.register_stat :meetings_count, primary: true, priority: Decidim::StatsRegistry::MEDIUM_PRIORITY do |components, start_at, end_at|
    meetings = Decidim::Meetings::FilteredMeetings.for(components, start_at, end_at).except_withdrawn
    meetings.count
  end

  component.register_stat :followers_count, tag: :followers, priority: Decidim::StatsRegistry::LOW_PRIORITY do |components, start_at, end_at|
    meetings_ids = Decidim::Meetings::FilteredMeetings.for(components, start_at, end_at).pluck(:id)
    Decidim::Follow.where(decidim_followable_type: "Decidim::Meetings::Meeting", decidim_followable_id: meetings_ids).count
  end

  component.register_stat :comments_count, tag: :comments do |components, start_at, end_at|
    meetings = Decidim::Meetings::FilteredMeetings.for(components, start_at, end_at).not_hidden
    meetings.sum(:comments_count)
  end

  component.exports :meetings do |exports|
    exports.collection do |component_instance|
      Decidim::Meetings::Meeting
        .not_hidden
        .visible
        .where(component: component_instance)
        .includes(:scope, :category, :attachments, component: { participatory_space: :organization })
    end

    exports.include_in_open_data = true

    exports.serializer Decidim::Meetings::MeetingSerializer
  end

  component.exports :meeting_comments do |exports|
    exports.collection do |component_instance|
      Decidim::Comments::Export.comments_for_resource(
        Decidim::Meetings::Meeting, component_instance
      ).includes(:author, :user_group, root_commentable: { component: { participatory_space: :organization } })
    end

    exports.include_in_open_data = true

    exports.serializer Decidim::Comments::CommentSerializer
  end

  component.exports :answers do |exports|
    exports.collection do |_component, _user, resource_id|
      Decidim::Meetings::QuestionnaireUserAnswers.for(resource_id)
    end

    exports.formats %w(CSV JSON Excel FormPDF)

    exports.serializer Decidim::Meetings::UserAnswersSerializer
  end

  component.actions = %w(join comment)

  component.settings(:global) do |settings|
    settings.attribute :scopes_enabled, type: :boolean, default: false
    settings.attribute :scope_id, type: :scope
    settings.attribute :announcement, type: :text, translated: true, editor: true
    settings.attribute :default_registration_terms, type: :text, translated: true, editor: true
    settings.attribute :comments_enabled, type: :boolean, default: true
    settings.attribute :comments_max_length, type: :integer, required: false
    settings.attribute :registration_code_enabled, type: :boolean, default: true
    settings.attribute :resources_permissions_enabled, type: :boolean, default: true
    settings.attribute :enable_pads_creation, type: :boolean, default: false
    settings.attribute :creation_enabled_for_participants, type: :boolean, default: false
    settings.attribute :maps_enabled, type: :boolean, default: true
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
      participatory_space:
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
      start_time = [rand(1..20).weeks.from_now, rand(1..20).weeks.ago].sample
      end_time = start_time + [rand(1..4).hours, rand(1..20).days].sample
      params = {
        component:,
        scope: Faker::Boolean.boolean(true_ratio: 0.5) ? global : scopes.sample,
        category: participatory_space.categories.sample,
        title: Decidim::Faker::Localized.sentence(word_count: 2),
        description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
          Decidim::Faker::Localized.paragraph(sentence_count: 3)
        end,
        location: Decidim::Faker::Localized.sentence,
        location_hints: Decidim::Faker::Localized.sentence,
        start_time:,
        end_time:,
        address: "#{Faker::Address.street_address} #{Faker::Address.zip} #{Faker::Address.city}",
        latitude: Faker::Address.latitude,
        longitude: Faker::Address.longitude,
        registrations_enabled: [true, false].sample,
        available_slots: (10..50).step(10).to_a.sample,
        author: participatory_space.organization,
        registration_terms: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
          Decidim::Faker::Localized.paragraph(sentence_count: 3)
        end,
        published_at: Faker::Boolean.boolean(true_ratio: 0.8) ? Time.current : nil
      }

      _hybrid_meeting = Decidim.traceability.create!(
        Decidim::Meetings::Meeting,
        admin_user,
        params.merge(
          title: Decidim::Faker::Localized.sentence(word_count: 2),
          type_of_meeting: :hybrid,
          online_meeting_url: "http://example.org"
        ),
        visibility: "all"
      )

      _online_meeting = Decidim.traceability.create!(
        Decidim::Meetings::Meeting,
        admin_user,
        params.merge(
          title: Decidim::Faker::Localized.sentence(word_count: 2),
          type_of_meeting: :online,
          online_meeting_url: "http://example.org"
        ),
        visibility: "all"
      )

      meeting = Decidim.traceability.create!(
        Decidim::Meetings::Meeting,
        admin_user,
        params,
        visibility: "all"
      )

      2.times do
        Decidim::Meetings::Service.create!(
          meeting:,
          title: Decidim::Faker::Localized.sentence(word_count: 2),
          description: Decidim::Faker::Localized.sentence(word_count: 5)
        )
      end

      Decidim::Forms::Questionnaire.create!(
        title: Decidim::Faker::Localized.paragraph,
        description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
          Decidim::Faker::Localized.paragraph(sentence_count: 3)
        end,
        tos: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
          Decidim::Faker::Localized.paragraph(sentence_count: 2)
        end,
        questionnaire_for: meeting
      )

      2.times do |n|
        email = "meeting-registered-user-#{meeting.id}-#{n}@example.org"
        name = "#{Faker::Name.name} #{meeting.id} #{n}"
        user = Decidim::User.find_or_initialize_by(email:)

        user.update!(
          password: "decidim123456",
          password_confirmation: "decidim123456",
          name:,
          nickname: Faker::Twitter.unique.screen_name,
          organization: component.organization,
          tos_agreement: "1",
          confirmed_at: Time.current,
          personal_url: Faker::Internet.url,
          about: Faker::Lorem.paragraph(sentence_count: 2)
        )

        Decidim::Meetings::Registration.create!(
          meeting:,
          user:
        )
      end

      attachment_collection = Decidim::AttachmentCollection.create!(
        name: Decidim::Faker::Localized.word,
        description: Decidim::Faker::Localized.sentence(word_count: 5),
        collection_for: meeting
      )

      Decidim::Attachment.create!(
        title: Decidim::Faker::Localized.sentence(word_count: 2),
        description: Decidim::Faker::Localized.sentence(word_count: 5),
        attachment_collection:,
        attached_to: meeting,
        content_type: "application/pdf",
        file: ActiveStorage::Blob.create_and_upload!(
          io: File.open(File.join(__dir__, "seeds", "Exampledocument.pdf")),
          filename: "Exampledocument.pdf",
          content_type: "application/pdf",
          metadata: nil
        ) # Keep after attached_to
      )
      Decidim::Attachment.create!(
        title: Decidim::Faker::Localized.sentence(word_count: 2),
        description: Decidim::Faker::Localized.sentence(word_count: 5),
        attached_to: meeting,
        content_type: "image/jpeg",
        file: ActiveStorage::Blob.create_and_upload!(
          io: File.open(File.join(__dir__, "seeds", "city.jpeg")),
          filename: "city.jpeg",
          content_type: "image/jpeg",
          metadata: nil
        ) # Keep after attached_to
      )
      Decidim::Attachment.create!(
        title: Decidim::Faker::Localized.sentence(word_count: 2),
        description: Decidim::Faker::Localized.sentence(word_count: 5),
        attached_to: meeting,
        content_type: "application/pdf",
        file: ActiveStorage::Blob.create_and_upload!(
          io: File.open(File.join(__dir__, "seeds", "Exampledocument.pdf")),
          filename: "Exampledocument.pdf",
          content_type: "application/pdf",
          metadata: nil
        ) # Keep after attached_to
      )
    end

    authors = [
      Decidim::UserGroup.where(decidim_organization_id: participatory_space.decidim_organization_id).verified.sample,
      Decidim::User.where(decidim_organization_id: participatory_space.decidim_organization_id).all.sample
    ]

    authors.each do |author|
      user_group = nil

      if author.is_a?(Decidim::UserGroup)
        user_group = author
        author = user_group.users.sample
      end

      start_time = [rand(1..20).weeks.from_now, rand(1..20).weeks.ago].sample
      params = {
        component:,
        scope: Faker::Boolean.boolean(true_ratio: 0.5) ? global : scopes.sample,
        category: participatory_space.categories.sample,
        title: Decidim::Faker::Localized.sentence(word_count: 2),
        description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
          Decidim::Faker::Localized.paragraph(sentence_count: 3)
        end,
        location: Decidim::Faker::Localized.sentence,
        location_hints: Decidim::Faker::Localized.sentence,
        start_time:,
        end_time: start_time + rand(1..4).hours,
        address: "#{Faker::Address.street_address} #{Faker::Address.zip} #{Faker::Address.city}",
        latitude: Faker::Address.latitude,
        longitude: Faker::Address.longitude,
        registrations_enabled: [true, false].sample,
        available_slots: (10..50).step(10).to_a.sample,
        author:,
        user_group:
      }

      Decidim.traceability.create!(
        Decidim::Meetings::Meeting,
        authors[0],
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
