# frozen_string_literal: true

require "decidim/components/namer"

Decidim.register_component(:budgets_groups) do |component|
  component.engine = Decidim::Budgets::Groups::Engine
  component.admin_engine = Decidim::Budgets::Groups::AdminEngine
  component.icon = "decidim/budgets/groups/icon.svg"
  component.stylesheet = "decidim/budgets/groups/budgets_groups"
  component.permissions_class_name = "Decidim::Budgets::Groups::Permissions"

  component.allow_children = true

  component.settings(:global) do |settings|
    settings.attribute :announcement, type: :text, translated: true, editor: true
  end

  component.settings(:step) do |settings|
    settings.attribute :announcement, type: :text, translated: true, editor: true
  end

  component.register_stat :budgets_count, primary: true, priority: Decidim::StatsRegistry::LOW_PRIORITY do |components, start_at, end_at|
    components.sum { |component| component.children.count }
  end

  component.seeds do |participatory_space|
    component = Decidim::Component.create!(
      name: Decidim::Components::Namer.new(participatory_space.organization.available_locales, :budgets_groups).i18n_name,
      manifest_name: :budgets_groups,
      published_at: Time.current,
      participatory_space: participatory_space
    )

    3.times do
      child_component = Decidim.find_component_manifest(:budgets).seed!(participatory_space)
      child_component.update_attributes name: Decidim::Faker::Localized.sentence(2), parent_id: component.id
    end
  end
end
