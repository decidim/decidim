# frozen_string_literal: true

require_dependency "decidim/components/namer"

Decidim.register_component(:elections) do |component|
  component.engine = Decidim::Elections::Engine
  component.admin_engine = Decidim::Elections::AdminEngine
  component.icon = "decidim/elections/icon.svg"
  component.permissions_class_name = "Decidim::Elections::Permissions"

  # component.on(:before_destroy) do |instance|
  #   # Code executed before removing the component
  # end

  # These actions permissions can be configured in the admin panel
  # component.actions = %w()

  component.settings(:global) do |settings|
    settings.attribute :announcement, type: :text, translated: true, editor: true
  end

  component.settings(:step) do |settings|
    settings.attribute :announcement, type: :text, translated: true, editor: true
  end

  component.register_resource(:election) do |resource|
    resource.model_class_name = "Decidim::Elections::Election"
  end

  component.register_stat :elections_count, primary: true, priority: Decidim::StatsRegistry::HIGH_PRIORITY do |components, _start_at, _end_at|
    Decidim::Elections::Election.where(component: components).count
  end

  # component.register_stat :some_stat do |context, start_at, end_at|
  #   # Register some stat number to the application
  # end

  # component.seeds do |participatory_space|
  #   # Add some seeds for this component
  # end
end
