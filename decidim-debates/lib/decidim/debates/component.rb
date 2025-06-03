# frozen_string_literal: true

Decidim.register_component(:debates) do |component|
  component.engine = Decidim::Debates::Engine
  component.admin_engine = Decidim::Debates::AdminEngine
  component.icon = "media/images/decidim_debates.svg"
  component.icon_key = "discuss-line"
  component.permissions_class_name = "Decidim::Debates::Permissions"

  component.query_type = "Decidim::Debates::DebatesType"
  component.data_portable_entities = ["Decidim::Debates::Debate"]

  component.newsletter_participant_entities = ["Decidim::Debates::Debate"]

  component.on(:before_destroy) do |instance|
    raise StandardError, "Cannot remove this component" if Decidim::Debates::Debate.where(component: instance).any?
  end

  component.settings(:global) do |settings|
    settings.attribute :taxonomy_filters, type: :taxonomy_filters
    settings.attribute :comments_enabled, type: :boolean, default: true
    settings.attribute :comments_max_length, type: :integer, required: true
    settings.attribute :announcement, type: :text, translated: true, editor: true
    settings.attribute :attachments_allowed, type: :boolean, default: false
  end

  component.settings(:step) do |settings|
    settings.attribute :likes_enabled, type: :boolean, default: true
    settings.attribute :likes_blocked, type: :boolean
    settings.attribute :creation_enabled, type: :boolean, default: false
    settings.attribute :comments_blocked, type: :boolean, default: false
    settings.attribute :announcement, type: :text, translated: true, editor: true
  end

  component.register_stat :debates_count,
                          primary: true,
                          priority: Decidim::StatsRegistry::MEDIUM_PRIORITY,
                          icon_name: "discuss-line",
                          tooltip_key: "debates_count_tooltip" do |components, _start_at, _end_at|
    Decidim::Debates::Debate.where(component: components).not_hidden.count
  end

  component.register_stat :followers_count,
                          tag: :followers,
                          icon_name: "user-follow-line",
                          tooltip_key: "followers_count_tooltip",
                          priority: Decidim::StatsRegistry::MEDIUM_PRIORITY do |components, _start_at, _end_at|
    debates_ids = Decidim::Debates::Debate.where(component: components).not_hidden.pluck(:id)
    Decidim::Follow.where(decidim_followable_type: "Decidim::Debates::Debate", decidim_followable_id: debates_ids).count
  end

  component.register_stat :comments_count,
                          priority: Decidim::StatsRegistry::HIGH_PRIORITY,
                          icon_name: "chat-1-line",
                          tooltip_key: "comments_count",
                          tag: :comments do |components, _start_at, _end_at|
    Decidim::Debates::Debate.where(component: components).not_hidden.count
  end

  component.register_stat :likes_count, priority: Decidim::StatsRegistry::LOW_PRIORITY do |components, _start_at, _end_at|
    debates_ids = Decidim::Debates::Debate.where(component: components).not_hidden.pluck(:id)
    Decidim::Like.where(resource_id: debates_ids, resource_type: Decidim::Debates::Debate.name).count
  end

  component.register_resource(:debate) do |resource|
    resource.model_class_name = "Decidim::Debates::Debate"
    resource.card = "decidim/debates/debate"
    resource.reported_content_cell = "decidim/debates/reported_content"
    resource.searchable = true
    resource.actions = %w(create like comment)
  end

  component.actions = %w(create like comment)

  component.exports :debates do |exports|
    exports.collection do |component_instance|
      Decidim::Debates::Debate
        .not_hidden
        .where(component: component_instance)
        .includes(:taxonomies, component: { participatory_space: :organization })
    end

    exports.include_in_open_data = true

    exports.serializer Decidim::Debates::DebateSerializer
  end

  component.exports :debate_comments do |exports|
    exports.collection do |component_instance|
      Decidim::Comments::Export.comments_for_resource(
        Decidim::Debates::Debate, component_instance
      ).includes(:author, root_commentable: { component: { participatory_space: :organization } })
    end

    exports.include_in_open_data = true

    exports.serializer Decidim::Comments::CommentSerializer
  end

  component.seeds do |participatory_space|
    require "decidim/debates/seeds"

    Decidim::Debates::Seeds.new(participatory_space:).call
  end
end
