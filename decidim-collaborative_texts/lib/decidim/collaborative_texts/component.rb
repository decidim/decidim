# frozen_string_literal: true

Decidim.register_component(:collaborative_texts) do |component|
  component.engine = Decidim::CollaborativeTexts::Engine
  component.admin_engine = Decidim::CollaborativeTexts::AdminEngine
  component.icon = "media/images/decidim_collaborative_texts.svg"
  component.icon_key = "draft-line"
  component.permissions_class_name = "Decidim::CollaborativeTexts::Permissions"

  # component.query_type = "Decidim::CollaborativeTexts::CollaborativeTextsType"

  # component.register_stat ...
  component.register_stat :collaborative_texts_count,
                          primary: true,
                          priority: Decidim::StatsRegistry::MEDIUM_PRIORITY,
                          icon_name: "draft-line",
                          tooltip_key: "collaborative_texts_count_tooltip" do |components, start_at, end_at|
    collaborative_texts = Decidim::CollaborativeTexts::Document.where(component: components).published
    collaborative_texts = collaborative_texts.where(created_at: start_at..) if start_at.present?
    collaborative_texts = collaborative_texts.where(created_at: ..end_at) if end_at.present?
    collaborative_texts.count
  end

  component.actions = %w(create update destroy)

  component.settings(:global) do |settings|
    settings.attribute :announcement, type: :text, translated: true, editor: true
  end

  component.settings(:step) do |settings|
    settings.attribute :announcement, type: :text, translated: true, editor: true
  end

  component.register_resource(:collaborative_text) do |resource|
    resource.model_class_name = "Decidim::CollaborativeTexts::Document"
    resource.card = "decidim/collaborative_texts/document"
    resource.searchable = true
  end

  # component.exports ...

  component.seeds do |participatory_space|
    require "decidim/collaborative_texts/seeds"

    Decidim::CollaborativeTexts::Seeds.new(participatory_space:).call
  end
end
