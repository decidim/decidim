# frozen_string_literal: true

require "decidim/blogs/seeds"

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

  component.register_stat :posts_count, primary: true, priority: Decidim::StatsRegistry::MEDIUM_PRIORITY do |components, _start_at, _end_at|
    Decidim::Blogs::Post.where(component: components).count
  end

  component.actions = %w(create update destroy)

  component.settings(:global) do |settings|
    settings.attribute :announcement, type: :text, translated: true, editor: true
    settings.attribute :comments_enabled, type: :boolean, default: true
    settings.attribute :comments_max_length, type: :integer, required: true
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
    resource.actions = %w(endorse comment)
    resource.searchable = true
  end

  component.seeds do |participatory_space|
    Decidim::Blogs::Seeds.new(participatory_space:).call
  end
end
