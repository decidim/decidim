# frozen_string_literal: true

Decidim.register_component(:budgets) do |component|
  component.engine = Decidim::Budgets::Engine
  component.admin_engine = Decidim::Budgets::AdminEngine
  component.icon = "media/images/decidim_budgets.svg"
  component.icon_key = "coin-line"
  component.stylesheet = "decidim/budgets/budgets"
  component.permissions_class_name = "Decidim::Budgets::Permissions"
  component.component_form_class_name = "Decidim::Budgets::Admin::ComponentForm"

  component.data_portable_entities = ["Decidim::Budgets::Order"]

  component.newsletter_participant_entities = ["Decidim::Budgets::Order"]

  component.query_type = "Decidim::Budgets::BudgetsType"

  component.actions = %w(vote comment)

  component.on(:before_destroy) do |instance|
    raise StandardError, "Cannot remove this component" if Decidim::Budgets::Budget.where(component: instance).any?
  end

  component.register_resource(:budget) do |resource|
    resource.model_class_name = "Decidim::Budgets::Budget"
    resource.card = "decidim/budgets/budget"
    resource.searchable = true
  end

  component.register_resource(:project) do |resource|
    resource.model_class_name = "Decidim::Budgets::Project"
    resource.template = "decidim/budgets/projects/linked_projects"
    resource.card = "decidim/budgets/project"
    resource.actions = %w(vote comment)
    resource.searchable = true
  end

  component.register_stat :budgets_count, primary: true, priority: Decidim::StatsRegistry::LOW_PRIORITY do |components|
    Decidim::Budgets::Budget.where(component: components).count
  end

  component.register_stat :projects_count,
                          priority: Decidim::StatsRegistry::MEDIUM_PRIORITY,
                          sub_title: "votes",
                          icon_name: "git-pull-request-line",
                          tooltip_key: "projects_count_tooltip" do |components, start_at, end_at|
    budgets = Decidim::Budgets::Budget.where(component: components)
    projects = Decidim::Budgets::FilteredProjects.for(components, start_at, end_at)
    orders = Decidim::Budgets::Order.where(budget: budgets)
    orders = orders.where(created_at: start_at..) if start_at.present?
    orders = orders.where(created_at: ..end_at) if end_at.present?
    [
      projects.count,
      orders.count
    ]
  end

  component.register_stat :comments_count,
                          priority: Decidim::StatsRegistry::HIGH_PRIORITY,
                          icon_name: "chat-1-line",
                          tooltip_key: "comments_count",
                          tag: :comments do |components, start_at, end_at|
    projects = Decidim::Budgets::FilteredProjects.for(components, start_at, end_at)
    projects.sum(:comments_count)
  end

  component.register_stat :followers_count,
                          tag: :followers,
                          icon_name: "user-follow-line",
                          tooltip_key: "followers_count_tooltip",
                          priority: Decidim::StatsRegistry::MEDIUM_PRIORITY do |components, start_at, end_at|
    projects_ids = Decidim::Budgets::FilteredProjects.for(components, start_at, end_at).pluck(:id)
    Decidim::Follow.where(decidim_followable_type: "Decidim::Budgets::Project", decidim_followable_id: projects_ids).count
  end

  component.exports :projects do |exports|
    exports.collection do |component_instance, _user, resource_id|
      budgets = resource_id ? Decidim::Budgets::Budget.find(resource_id) : Decidim::Budgets::Budget.where(decidim_component_id: component_instance)
      Decidim::Budgets::Project
        .where(decidim_budgets_budget_id: budgets)
        .includes(:taxonomies, :component)
    end

    exports.include_in_open_data = true

    exports.serializer Decidim::Budgets::ProjectSerializer
  end

  component.settings(:global) do |settings|
    settings.attribute :taxonomy_filters, type: :taxonomy_filters
    settings.attribute :workflow, type: :enum, default: "one", choices: ->(_context) { Decidim::Budgets.workflows.keys.map(&:to_s) }
    settings.attribute :projects_per_page, type: :integer, default: 12
    settings.attribute :vote_rule_threshold_percent_enabled, type: :boolean, default: true
    settings.attribute :vote_threshold_percent, type: :integer, default: 70
    settings.attribute :vote_threshold_percent, type: :integer, default: 70
    settings.attribute :vote_rule_minimum_budget_projects_enabled, type: :boolean, default: false
    settings.attribute :vote_minimum_budget_projects_number, type: :integer, default: 1
    settings.attribute :vote_rule_selected_projects_enabled, type: :boolean, default: false
    settings.attribute :vote_selected_projects_minimum, type: :integer, default: 0
    settings.attribute :vote_selected_projects_maximum, type: :integer, default: 1
    settings.attribute :comments_enabled, type: :boolean, default: true
    settings.attribute :comments_max_length, type: :integer, required: true
    settings.attribute :geocoding_enabled, type: :boolean, default: false
    settings.attribute :resources_permissions_enabled, type: :boolean, default: true
    settings.attribute :announcement, type: :text, translated: true, editor: true

    settings.attribute :landing_page_content, type: :text, translated: true, editor: true
    settings.attribute :more_information_modal, type: :text, translated: true
  end

  component.settings(:step) do |settings|
    settings.attribute :comments_blocked, type: :boolean, default: false
    settings.attribute :votes, type: :enum, default: "enabled", choices: %w(disabled enabled finished)
    settings.attribute :show_votes, type: :boolean, default: false
    settings.attribute :announcement, type: :text, translated: true, editor: true

    settings.attribute :landing_page_content, type: :text, translated: true, editor: true
    settings.attribute :more_information_modal, type: :text, translated: true
    settings.attribute :announcement, type: :text, translated: true, editor: true
  end

  component.seeds do |participatory_space|
    require "decidim/budgets/seeds"

    Decidim::Budgets::Seeds.new(participatory_space:).call
  end
end
