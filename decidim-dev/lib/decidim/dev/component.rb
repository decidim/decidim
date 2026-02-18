# frozen_string_literal: true

Decidim.register_component(:dummy) do |component|
  component.engine = Decidim::Dev::Engine
  component.admin_engine = Decidim::Dev::AdminEngine
  component.icon = "media/images/decidim_dev_dummy.svg"

  component.actions = %w(foo bar)

  component.newsletter_participant_entities = ["Decidim::Dev::DummyResource"]
  component.permissions_class_name = "Decidim::Dev::Permissions"

  component.settings(:global) do |settings|
    settings.attribute :taxonomy_filters, type: :taxonomy_filters, default: []
    settings.attribute :comments_enabled, type: :boolean, default: true
    settings.attribute :comments_max_length, type: :integer, required: false
    settings.attribute :resources_permissions_enabled, type: :boolean, default: true
    settings.attribute :dummy_global_attribute1, type: :boolean
    settings.attribute :dummy_global_attribute2, type: :boolean, readonly: ->(_context) { false }
    settings.attribute :readonly_attribute, type: :boolean, default: true, readonly: ->(_context) { true }
    settings.attribute :enable_pads_creation, type: :boolean, default: false
    settings.attribute :amendments_enabled, type: :boolean, default: false
    settings.attribute :dummy_global_translatable_text, type: :text, translated: true, editor: true, required: true
  end

  component.settings(:step) do |settings|
    settings.attribute :comments_blocked, type: :boolean, default: false
    settings.attribute :dummy_step_attribute1, type: :boolean
    settings.attribute :dummy_step_attribute2, type: :boolean, readonly: ->(_context) { false }
    settings.attribute :dummy_step_translatable_text, type: :text, translated: true, editor: true, required: true
    settings.attribute :readonly_step_attribute, type: :boolean, default: true, readonly: ->(_context) { true }
    settings.attribute :amendment_creation_enabled, type: :boolean, default: true
    settings.attribute :amendment_reaction_enabled, type: :boolean, default: true
    settings.attribute :amendment_promotion_enabled, type: :boolean, default: true
    settings.attribute :amendments_visibility, type: :string, default: "all"
    settings.attribute :likes_enabled, type: :boolean, default: false
    settings.attribute :likes_blocked, type: :boolean, default: false
  end

  component.register_resource(:dummy_resource) do |resource|
    resource.name = :dummy
    resource.model_class_name = "Decidim::Dev::DummyResource"
    resource.template = "decidim/dummy_resource/linked_dummies"
    resource.actions = %w(foo)
    resource.searchable = true
  end

  component.register_resource(:nested_dummy_resource) do |resource|
    resource.name = :nested_dummy
    resource.model_class_name = "Decidim::Dev::NestedDummyResource"
  end

  component.register_resource(:coauthorable_dummy_resource) do |resource|
    resource.name = :coauthorable_dummy
    resource.model_class_name = "Decidim::Dev::CoauthorableDummyResource"
    resource.template = "decidim/coauthorabledummy_resource/linked_dummies"
    resource.actions = %w(foo-coauthorable)
    resource.searchable = false
  end

  component.register_stat :dummies_count_high, primary: true, priority: Decidim::StatsRegistry::HIGH_PRIORITY do |components, _start_at, _end_at|
    components.count * 10
  end

  component.register_stat :dummies_count_medium, primary: true, priority: Decidim::StatsRegistry::MEDIUM_PRIORITY do |components, _start_at, _end_at|
    components.count * 100
  end

  component.exports :dummies do |exports|
    exports.collection do
      [1, 2, 3]
    end

    exports.serializer Decidim::Dev::DummySerializer
  end

  component.imports :dummies do |imports|
    imports.messages do |msg|
      msg.set(:resource_name) { |count: 1| count == 1 ? "Dummy" : "Dummies" }
      msg.set(:title) { "Import dummies" }
      msg.set(:label) { "Import dummies from a file" }
    end

    imports.creator DummyCreator
    imports.example do |import_component|
      locales = import_component.organization.available_locales
      translated = ->(name) { locales.map { |l| "#{name}/#{l}" } }
      [
        translated.call("title") + %w(body) + translated.call("translatable_text") + %w(address latitude longitude),
        locales.map { "Title text" } + ["Body text"] + locales.map { "Translatable text" } + ["Fake street 1", 1.0, 1.0]
      ]
    end
  end
end
