# frozen_string_literal: true

require_dependency "decidim/components/namer"

Decidim.register_component(:debates) do |component|
  component.engine = Decidim::Debates::Engine
  component.admin_engine = Decidim::Debates::AdminEngine
  component.icon = "decidim/debates/icon.svg"
  component.permissions_class_name = "Decidim::Debates::Permissions"

  component.on(:before_destroy) do |instance|
    raise StandardError, "Can't remove this component" if Decidim::Debates::Debate.where(component: instance).any?
  end

  component.settings(:global) do |settings|
    settings.attribute :comments_enabled, type: :boolean, default: true
    settings.attribute :announcement, type: :text, translated: true, editor: true
  end

  component.settings(:step) do |settings|
    settings.attribute :creation_enabled, type: :boolean, default: false
    settings.attribute :comments_blocked, type: :boolean, default: false
    settings.attribute :announcement, type: :text, translated: true, editor: true
  end

  component.register_stat :debates_count, primary: true, priority: Decidim::StatsRegistry::HIGH_PRIORITY do |components, _start_at, _end_at|
    Decidim::Debates::Debate.where(component: components).count
  end

  component.exports :debates do |exports|
    exports.collection do |component_instance|
      Decidim::Debates::Debate
        .where(component: component_instance)
        .includes(:category, component: { participatory_space: :organization })
    end

    exports.serializer Decidim::Debates::DebateSerializer
  end

  component.exports :comments do |exports|
    exports.collection do |component_instance|
      Decidim::Comments::Export.comments_for_resource(
        Decidim::Debates::Debate, component_instance
      )
    end

    exports.serializer Decidim::Comments::CommentSerializer
  end

  component.register_resource(:debate) do |resource|
    resource.model_class_name = "Decidim::Debates::Debate"
    resource.card = "decidim/debates/debate"
  end

  component.actions = %w(create)

  component.seeds do |participatory_space|
    component = Decidim::Component.create!(
      name: Decidim::Components::Namer.new(participatory_space.organization.available_locales, :debates).i18n_name,
      manifest_name: :debates,
      published_at: Time.current,
      participatory_space: participatory_space
    )

    3.times do
      debate = Decidim::Debates::Debate.create!(
        component: component,
        category: participatory_space.categories.sample,
        title: Decidim::Faker::Localized.sentence(2),
        description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
          Decidim::Faker::Localized.paragraph(3)
        end,
        instructions: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
          Decidim::Faker::Localized.paragraph(3)
        end,
        start_time: 3.weeks.from_now,
        end_time: 3.weeks.from_now + 4.hours
      )

      Decidim::Comments::Seed.comments_for(debate)
    end
  end
end
