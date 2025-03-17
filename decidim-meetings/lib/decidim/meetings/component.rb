# frozen_string_literal: true

Decidim.register_component(:meetings) do |component|
  component.engine = Decidim::Meetings::Engine
  component.admin_engine = Decidim::Meetings::AdminEngine
  component.icon = "media/images/decidim_meetings.svg"
  component.icon_key = "map-pin-line"
  component.permissions_class_name = "Decidim::Meetings::Permissions"

  component.query_type = "Decidim::Meetings::MeetingsType"
  component.data_portable_entities = [
    "Decidim::Meetings::Registration",
    "Decidim::Meetings::Invite",
    "Decidim::Meetings::Meeting"
  ]

  component.on(:before_destroy) do |instance|
    raise StandardError, "Cannot remove this component" if Decidim::Meetings::Meeting.where(component: instance).any?
  end

  component.register_resource(:meeting) do |resource|
    resource.model_class_name = "Decidim::Meetings::Meeting"
    resource.template = "decidim/meetings/meetings/linked_meetings"
    resource.card = "decidim/meetings/meeting"
    resource.reported_content_cell = "decidim/meetings/reported_content"
    resource.actions = %w(join comment reply_poll)
    resource.searchable = true
  end

  component.register_stat :meetings_count, primary: true, priority: Decidim::StatsRegistry::MEDIUM_PRIORITY do |components, start_at, end_at|
    meetings = Decidim::Meetings::FilteredMeetings.for(components, start_at, end_at).not_withdrawn
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

  component.register_stat :attendees_count, primary: true, priority: Decidim::StatsRegistry::MEDIUM_PRIORITY do |components, start_at, end_at|
    meetings = Decidim::Meetings::Meeting.closed.not_hidden.published.where(component: components, closing_visible: true)
    meetings = meetings.where(closed_at: start_at..) if start_at.present?
    meetings = meetings.where(closed_at: ..end_at) if end_at.present?
    meetings.sum(:attendees_count)
  end

  component.exports :meetings do |exports|
    exports.collection do |component_instance|
      Decidim::Meetings::Meeting
        .not_hidden
        .visible
        .where(component: component_instance)
        .includes(:taxonomies, :attachments, component: { participatory_space: :organization })
    end

    exports.include_in_open_data = true

    exports.serializer Decidim::Meetings::MeetingSerializer
  end

  component.exports :meeting_comments do |exports|
    exports.collection do |component_instance|
      Decidim::Comments::Export.comments_for_resource(
        Decidim::Meetings::Meeting, component_instance
      ).includes(:author, root_commentable: { component: { participatory_space: :organization } })
    end

    exports.include_in_open_data = true

    exports.serializer Decidim::Comments::CommentSerializer
  end

  component.exports :responses do |exports|
    exports.collection do |_component, _user, resource_id|
      Decidim::Meetings::QuestionnaireUserResponses.for(resource_id)
    end

    exports.formats %w(CSV JSON Excel FormPDF)

    exports.serializer Decidim::Meetings::UserResponsesSerializer
  end

  component.actions = %w(join comment)

  component.settings(:global) do |settings|
    settings.attribute :taxonomy_filters, type: :taxonomy_filters
    settings.attribute :announcement, type: :text, translated: true, editor: true
    settings.attribute :default_registration_terms, type: :text, translated: true, editor: true
    settings.attribute :comments_enabled, type: :boolean, default: true
    settings.attribute :comments_max_length, type: :integer, required: true
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
    require "decidim/meetings/seeds"

    Decidim::Meetings::Seeds.new(participatory_space:).call
  end
end

Decidim.register_global_engine(
  :meetings_directory,
  Decidim::Meetings::DirectoryEngine,
  at: "/meetings"
)
