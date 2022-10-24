# frozen_string_literal: true

Decidim.register_component(:sortitions) do |component|
  component.engine = Decidim::Sortitions::Engine
  component.admin_engine = Decidim::Sortitions::AdminEngine
  component.icon = "media/images/decidim_sortitions.svg"
  # component.stylesheet = "decidim/sortitions/sortitions"
  component.permissions_class_name = "Decidim::Sortitions::Permissions"
  component.query_type = "Decidim::Sortitions::SortitionsType"

  component.on(:before_destroy) do |instance|
    raise StandardError, "Can't remove this component" if Decidim::Sortitions::Sortition.where(component: instance).any?
  end

  # These actions permissions can be configured in the admin panel
  component.actions = %w(comment)

  component.settings(:global) do |settings|
    settings.attribute :comments_enabled, type: :boolean, default: true
    settings.attribute :comments_max_length, type: :integer, required: false
  end

  # Register an optional resource that can be referenced from other resources.
  component.register_resource(:sortition) do |resource|
    resource.model_class_name = "Decidim::Sortitions::Sortition"
    resource.template = "decidim/sortitions/sortitions/linked_sortitions"
    resource.card = "decidim/sortitions/sortition"
    resource.actions = %w(comment)
  end

  component.register_stat :sortitions_count, primary: true, priority: Decidim::StatsRegistry::HIGH_PRIORITY do |components, start_at, end_at|
    Decidim::Sortitions::FilteredSortitions.for(components, start_at, end_at).count
  end

  component.seeds do |participatory_space|
    component = Decidim::Component.create!(
      name: Decidim::Components::Namer.new(participatory_space.organization.available_locales, :sortitions).i18n_name,
      manifest_name: :sortitions,
      published_at: Time.current,
      participatory_space:
    )
  end
end
