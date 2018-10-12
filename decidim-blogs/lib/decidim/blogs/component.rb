# frozen_string_literal: true

require "decidim/components/namer"

Decidim.register_component(:blogs) do |component|
  component.engine = Decidim::Blogs::Engine
  component.admin_engine = Decidim::Blogs::AdminEngine
  component.icon = "decidim/blogs/icon.svg"
  component.permissions_class_name = "Decidim::Blog::Permissions"

  component.on(:before_destroy) do |instance|
    raise StandardError, "Can't remove this component" if Decidim::Blogs::Post.where(component: instance).any?
  end

  component.register_stat :posts_count, primary: true, priority: Decidim::StatsRegistry::MEDIUM_PRIORITY do |components, _start_at, _end_at|
    Decidim::Blogs::Post.where(component: components).count
  end

  component.settings(:global) do |settings|
    settings.attribute :announcement, type: :text, translated: true, editor: true
    settings.attribute :comments_enabled, type: :boolean, default: true
  end

  component.settings(:step) do |settings|
    settings.attribute :announcement, type: :text, translated: true, editor: true
    settings.attribute :comments_blocked, type: :boolean, default: false
  end

  component.register_resource(:blogpost) do |resource|
    resource.model_class_name = "Decidim::Blogs::Post"
    resource.card = "decidim/blogs/post"
  end

  component.seeds do |participatory_space|
    admin_user = Decidim::User.find_by(
      organization: participatory_space.organization,
      email: "admin@example.org"
    )

    step_settings = if participatory_space.allows_steps?
                      { participatory_space.active_step.id => { comments_enabled: true, comments_blocked: false } }
                    else
                      {}
                    end

    params = {
      name: Decidim::Components::Namer.new(participatory_space.organization.available_locales, :blogs).i18n_name,
      manifest_name: :blogs,
      published_at: Time.current,
      participatory_space: participatory_space,
      settings: {
        vote_limit: 0
      },
      step_settings: step_settings
    }

    component = Decidim.traceability.perform_action!(
      "publish",
      Decidim::Component,
      admin_user,
      visibility: "all"
    ) do
      Decidim::Component.create!(params)
    end

    5.times do
      author = Decidim::User.where(organization: component.organization).all.first

      params = {
        component: component,
        title: Decidim::Faker::Localized.sentence(5),
        body: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
          Decidim::Faker::Localized.paragraph(20)
        end,
        author: author
      }

      post = Decidim.traceability.create!(
        Decidim::Blogs::Post,
        author,
        params,
        visibility: "all"
      )

      Decidim::Comments::Seed.comments_for(post)
    end
  end
end
