# frozen_string_literal: true

Decidim.register_component(:sortitions) do |component|
  component.engine = Decidim::Sortitions::Engine
  component.admin_engine = Decidim::Sortitions::AdminEngine
  component.icon = "media/images/decidim_sortitions.svg"
  component.icon_key = "billiards-line"
  # component.stylesheet = "decidim/sortitions/sortitions"
  component.permissions_class_name = "Decidim::Sortitions::Permissions"
  component.query_type = "Decidim::Sortitions::SortitionsType"

  component.on(:before_destroy) do |instance|
    raise StandardError, "Cannot remove this component" if Decidim::Sortitions::Sortition.where(component: instance).any?
  end

  # These actions permissions can be configured in the admin panel
  component.actions = %w(comment)

  component.settings(:global) do |settings|
    settings.attribute :taxonomy_filters, type: :taxonomy_filters
    settings.attribute :comments_enabled, type: :boolean, default: true
    settings.attribute :comments_max_length, type: :integer, required: true
  end

  # Register an optional resource that can be referenced from other resources.
  component.register_resource(:sortition) do |resource|
    resource.model_class_name = "Decidim::Sortitions::Sortition"
    resource.template = "decidim/sortitions/sortitions/linked_sortitions"
    resource.card = "decidim/sortitions/sortition"
    resource.actions = %w(comment)
  end

  component.register_stat :sortitions_count,
                          primary: true,
                          priority: Decidim::StatsRegistry::MEDIUM_PRIORITY,
                          icon_name: "team-line",
                          tooltip_key: "sortitions_count_tooltip" do |components, start_at, end_at|
    Decidim::Sortitions::FilteredSortitions.for(components, start_at, end_at).count
  end

  component.seeds do |participatory_space|
    require "decidim/sortitions/seeds"

    Decidim::Sortitions::Seeds.new(participatory_space:).call
  end
end
