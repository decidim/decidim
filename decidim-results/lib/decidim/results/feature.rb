# frozen_string_literal: true

require "decidim/features/namer"

Decidim.register_feature(:results) do |feature|
  feature.engine = Decidim::Results::Engine
  feature.admin_engine = Decidim::Results::AdminEngine
  feature.icon = "decidim/results/icon.svg"

  feature.on(:before_destroy) do |instance|
    raise StandardError, "Can't remove this feature" if Decidim::Results::Result.where(feature: instance).any?
  end

  feature.register_resource do |resource|
    resource.model_class_name = "Decidim::Results::Result"
    resource.template = "decidim/results/results/linked_results"
  end

  feature.register_stat :results_count, primary: true, priority: Decidim::StatsRegistry::HIGH_PRIORITY do |features, start_at, end_at|
    Decidim::Results::FilteredResults.for(features, start_at, end_at).count
  end

  feature.register_stat :comments_count, tag: :comments do |features, start_at, end_at|
    results = Decidim::Results::FilteredResults.for(features, start_at, end_at)
    Decidim::Comments::Comment.where(root_commentable: results).count
  end

  feature.settings(:global) do |settings|
    settings.attribute :comments_enabled, type: :boolean, default: true
    settings.attribute :announcement, type: :text, translated: true, editor: true
  end

  feature.settings(:step) do |settings|
    settings.attribute :comments_blocked, type: :boolean, default: false
    settings.attribute :announcement, type: :text, translated: true, editor: true
  end

  feature.seeds do |process|
    feature = Decidim::Feature.create!(
      name: Decidim::Features::Namer.new(process.organization.available_locales, :results).i18n_name,
      manifest_name: :results,
      published_at: Time.current,
      participatory_process: process
    )

    3.times do
      result = Decidim::Results::Result.create!(
        feature: feature,
        scope: process.organization.scopes.sample,
        category: process.categories.sample,
        title: Decidim::Faker::Localized.sentence(2),
        description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
          Decidim::Faker::Localized.paragraph(3)
        end
      )

      Decidim::Comments::Seed.comments_for(result)
    end
  end
end
