# frozen_string_literal: true

Decidim.register_component(:collaborative_texts) do |component|
  component.engine = Decidim::CollaborativeTexts::Engine
  component.admin_engine = Decidim::CollaborativeTexts::AdminEngine
  component.icon = "media/images/decidim_collaborative_texts.svg"
  component.icon_key = "draft-line"
  # component.permissions_class_name = "Decidim::CollaborativeTexts::Permissions"

  # component.query_type = "Decidim::CollaborativeTexts::CollaborativeTextsType"

  # TODO:
  # component.register_stat ...

  component.actions = %w(create update destroy)

  component.settings(:global) do |settings|
    settings.attribute :announcement, type: :text, translated: true, editor: true
    settings.attribute :comments_blocked, type: :boolean, default: false
  end

  component.settings(:step) do |settings|
    settings.attribute :announcement, type: :text, translated: true, editor: true
  end

  # TODO: component.register_resource...

  # TODO: component.exports ...

  component.seeds do |participatory_space|
    require "decidim/collaborative_texts/seeds"

    Decidim::CollaborativeTexts::Seeds.new(participatory_space:).call
  end
end
