# frozen_string_literal: true

require "decidim/components/namer"

Decidim.register_component(:budgets_groups) do |component|
  component.engine = Decidim::Budgets::Groups::Engine
  component.admin_engine = Decidim::Budgets::Groups::AdminEngine
  component.icon = "decidim/budgets/groups/icon.svg"
  component.permissions_class_name = "Decidim::Budgets::Groups::Permissions"

  component.allow_children = true

  component.settings(:global) do |settings|
    settings.attribute :scopes_enabled, type: :boolean, default: false
    settings.attribute :scope_id, type: :scope
    settings.attribute :workflow, type: :enum, default: "one", choices: -> { Decidim::Budgets::Groups.workflows.keys.map(&:to_s) }
    settings.attribute :title, type: :string, translated: true
    settings.attribute :description, type: :text, translated: true
    settings.attribute :highlighted_heading, type: :text, translated: true
    settings.attribute :list_heading, type: :text, translated: true
    settings.attribute :more_information, type: :text, translated: true
    settings.attribute :announcement, type: :text, translated: true, editor: true
  end

  component.settings(:step) do |settings|
    settings.attribute :title, type: :string, translated: true
    settings.attribute :description, type: :text, translated: true
    settings.attribute :highlighted_heading, type: :text, translated: true
    settings.attribute :list_heading, type: :text, translated: true
    settings.attribute :more_information, type: :text, translated: true
    settings.attribute :announcement, type: :text, translated: true, editor: true
  end

  component.register_stat :budgets_count, primary: true, priority: Decidim::StatsRegistry::LOW_PRIORITY do |components, _start_at, _end_at|
    components.sum { |budgets_group_component| budgets_group_component.children.count }
  end

  component.on(:parent_context) do |context|
    group_component = context[:parent_component]
    current_user = context[:current_user]

    workflow_name = group_component.settings.workflow.to_sym || Decidim::Budgets::Groups.workflows.keys.first

    {
      workflow: workflow_name,
      workflow_instance: Decidim::Budgets::Groups.workflows[workflow_name].new(group_component, current_user)
    }
  end

  component.seeds do |participatory_space|
    budgets_group_component = Decidim::Component.create!(
      name: Decidim::Components::Namer.new(participatory_space.organization.available_locales, :budgets_groups).i18n_name,
      manifest_name: :budgets_groups,
      published_at: Time.current,
      participatory_space: participatory_space,
      settings: {
        title: Decidim::Faker::Localized.sentence(4),
        description: Decidim::Faker::Localized.paragraph(3),
        highlighted_heading: Decidim::Faker::Localized.sentence(4),
        list_heading: Decidim::Faker::Localized.sentence(4),
        more_information: Decidim::Faker::Localized.sentence(4),
        workflow: %w(one random all).sample
      }
    )

    3.times do
      child_component = Decidim.find_component_manifest(:budgets).seed!(participatory_space)
      child_component.update name: Decidim::Faker::Localized.sentence(2), parent_id: budgets_group_component.id
    end
  end
end
