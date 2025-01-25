# frozen_string_literal: true

Decidim.register_component(:accountability) do |component|
  component.engine = Decidim::Accountability::Engine
  component.admin_engine = Decidim::Accountability::AdminEngine
  component.icon = "media/images/decidim_accountability.svg"
  component.icon_key = "bar-chart-line"
  component.stylesheet = "decidim/accountability/accountability"
  component.permissions_class_name = "Decidim::Accountability::Permissions"
  component.query_type = "Decidim::Accountability::AccountabilityType"

  component.on(:before_destroy) do |instance|
    raise StandardError, "Cannot remove this component" if Decidim::Accountability::Result.where(component: instance).any?
  end

  # These actions permissions can be configured in the admin panel
  component.actions = %w(comment)

  component.register_resource(:result) do |resource|
    resource.model_class_name = "Decidim::Accountability::Result"
    resource.template = "decidim/accountability/results/linked_results"
    resource.card = "decidim/accountability/result"
    resource.searchable = false
    resource.actions = %w(comment)
  end

  component.settings(:global) do |settings|
    settings.attribute :taxonomy_filters, type: :taxonomy_filters
    settings.attribute :comments_enabled, type: :boolean, default: true
    settings.attribute :comments_max_length, type: :integer, required: true
    settings.attribute :intro, type: :text, translated: true, editor: true
    settings.attribute :display_progress_enabled, type: :boolean, default: true
    settings.attribute :geocoding_enabled, type: :boolean, default: false
  end

  component.register_stat :results_count, primary: true, priority: Decidim::StatsRegistry::HIGH_PRIORITY do |components, _start_at, _end_at|
    Decidim::Accountability::Result.where(component: components).count
  end

  component.settings(:step) do |settings|
    settings.attribute :comments_blocked, type: :boolean, default: false
  end

  component.exports :results do |exports|
    exports.collection do |component_instance|
      Decidim::Accountability::Result
        .where(component: component_instance)
        .includes(:taxonomies, :status, component: { participatory_space: :organization })
    end

    exports.include_in_open_data = true

    exports.serializer Decidim::Accountability::ResultSerializer
  end

  component.exports :result_comments do |exports|
    exports.collection do |component_instance|
      Decidim::Comments::Export.comments_for_resource(
        Decidim::Accountability::Result, component_instance
      ).includes(:author, :root_commentable, :commentable)
    end

    exports.include_in_open_data = true

    exports.serializer Decidim::Comments::CommentSerializer
  end

  component.seeds do |participatory_space|
    require "decidim/accountability/seeds"

    Decidim::Accountability::Seeds.new(participatory_space:).call
  end
end
