# frozen_string_literal: true

Decidim.register_component(:elections) do |component|
  component.engine = Decidim::Elections::Engine
  component.admin_engine = Decidim::Elections::AdminEngine
  component.stylesheet = "decidim/elections/elections"
  component.icon = "media/images/decidim_elections.svg"
  component.icon_key = "draft-line"
  component.permissions_class_name = "Decidim::Elections::Permissions"

  component.on(:publish) do |instance|
    Decidim::Elections::Election.where(component: instance).find_in_batches(batch_size: 100) do |batch|
      Decidim::UpdateSearchIndexesJob.perform_later(batch)
    end
  end

  component.on(:unpublish) do |instance|
    Decidim::Elections::Election.where(component: instance).find_in_batches(batch_size: 100) do |batch|
      Decidim::RemoveSearchIndexesJob.perform_later(batch)
    end
  end

  component.actions = %w()

  component.register_stat :elections_count, primary: true, priority: Decidim::StatsRegistry::HIGH_PRIORITY do |components, _start_at, _end_at|
    elections = Decidim::Elections::Election.where(component: components).not_hidden
    elections.count
  end

  component.settings(:global) do |settings|
    settings.attribute :announcement, type: :text, translated: true, editor: true
  end

  component.settings(:step) do |settings|
    settings.attribute :announcement, type: :text, translated: true, editor: true
  end

  component.register_resource(:election) do |resource|
    resource.model_class_name = "Decidim::Elections::Election"
    resource.card = "decidim/elections/election"
    resource.searchable = true
  end

  component.seeds do |participatory_space|
    require "decidim/elections/seeds"

    Decidim::Elections::Seeds.new(participatory_space:).call
  end
end
