# frozen_string_literal: true

require_dependency "decidim/features/namer"

Decidim.register_feature(:results) do |feature|
  feature.engine = Decidim::Results::ListEngine
  feature.admin_engine = Decidim::Results::AdminEngine
  feature.icon = "decidim/results/icon.svg"

  feature.on(:before_destroy) do |instance|
    raise StandardError, "Can't remove this feature" if Decidim::Results::Result.where(feature: instance).any?
  end

  feature.register_resource do |resource|
    resource.model_class_name = "Decidim::Results::Result"
    resource.template = "decidim/results/results/linked_results"
  end

  feature.register_stat :results_count, primary: true do |features, start_at, end_at|
    results = Decidim::Results::Result.where(feature: features)
    results = results.where("created_at >= ?", start_at) if start_at.present?
    results = results.where("created_at <= ?", end_at) if end_at.present?
    results.count
  end

  feature.settings(:global) do |settings|
    settings.attribute :comments_enabled, type: :boolean, default: true
  end

  feature.settings(:step) do |settings|
    settings.attribute :comments_blocked, type: :boolean, default: false
  end

  feature.seeds do
    Decidim::ParticipatoryProcess.all.each do |process|
      next unless process.steps.any?

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
end
