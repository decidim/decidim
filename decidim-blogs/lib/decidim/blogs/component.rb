# frozen_string_literal: true

Decidim.register_component(:blogs) do |component|
  component.engine = Decidim::Blogs::Engine
  component.admin_engine = Decidim::Blogs::AdminEngine
  component.icon = "media/images/decidim_blogs.svg"
  component.icon_key = "pen-nib-line"
  component.permissions_class_name = "Decidim::Blog::Permissions"

  component.query_type = "Decidim::Blogs::BlogsType"

  component.on(:before_destroy) do |instance|
    raise StandardError, "Cannot remove this component" if Decidim::Blogs::Post.where(component: instance).any?
  end

  component.register_stat :posts_count,
                          primary: true,
                          priority: Decidim::StatsRegistry::MEDIUM_PRIORITY,
                          icon_name: "pen-nib-line",
                          tooltip_key: "posts_count_tooltip" do |components, _start_at, _end_at|
    Decidim::Blogs::Post.where(component: components).count
  end

  component.register_stat :comments_count,
                          priority: Decidim::StatsRegistry::HIGH_PRIORITY,
                          icon_name: "chat-1-line",
                          tooltip_key: "comments_count",
                          tag: :comments do |components, _start_at, _end_at|
    Decidim::Blogs::Post.where(component: components).count
  end

  component.actions = %w(create update destroy)

  component.settings(:global) do |settings|
    settings.attribute :taxonomy_filters, type: :taxonomy_filters
    settings.attribute :announcement, type: :text, translated: true, editor: true
    settings.attribute :comments_enabled, type: :boolean, default: true
    settings.attribute :comments_max_length, type: :integer, required: true
    settings.attribute :creation_enabled_for_participants, type: :boolean, default: false
    settings.attribute :attachments_allowed, type: :boolean, default: false
  end

  component.settings(:step) do |settings|
    settings.attribute :announcement, type: :text, translated: true, editor: true
    settings.attribute :comments_blocked, type: :boolean, default: false
    settings.attribute :endorsements_enabled, type: :boolean, default: true
    settings.attribute :endorsements_blocked, type: :boolean
  end

  component.register_resource(:blogpost) do |resource|
    resource.model_class_name = "Decidim::Blogs::Post"
    resource.card = "decidim/blogs/post"
    resource.actions = %w(like comment)
    resource.searchable = true
  end

  component.exports :posts do |exports|
    exports.collection do |component_instance|
      Decidim::Blogs::Post
        .not_hidden
        .published
        .where(component: component_instance)
        .includes(component: { participatory_space: :organization })
    end

    exports.include_in_open_data = true

    exports.serializer Decidim::Blogs::PostSerializer
  end

  component.exports :post_comments do |exports|
    exports.collection do |component_instance|
      Decidim::Comments::Export.comments_for_resource(
        Decidim::Blogs::Post, component_instance
      ).includes(:author, root_commentable: { component: { participatory_space: :organization } })
    end

    exports.include_in_open_data = true

    exports.serializer Decidim::Comments::CommentSerializer
  end

  component.seeds do |participatory_space|
    require "decidim/blogs/seeds"

    Decidim::Blogs::Seeds.new(participatory_space:).call
  end
end
