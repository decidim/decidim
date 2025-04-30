# frozen_string_literal: true

Decidim.register_component(:elections) do |component|
  component.engine = Decidim::Elections::Engine
  component.admin_engine = Decidim::Elections::AdminEngine
  component.icon = "media/images/decidim_elections.svg"
  component.icon_key = "draft-line"

  component.actions = %w(create update destroy)

  component.settings(:global) do |settings|
    settings.attribute :announcement, type: :text, translated: true, editor: true
  end

  component.settings(:step) do |settings|
    settings.attribute :announcement, type: :text, translated: true, editor: true
  end

  component.seeds do |participatory_space|
    require "decidim/elections/seeds"

    Decidim::Elections::Seeds.new(participatory_space:).call
  end
end
