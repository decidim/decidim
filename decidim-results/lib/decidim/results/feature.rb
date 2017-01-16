# frozen_string_literal: true

require_dependency "decidim/features/namer"

Decidim.register_feature(:results) do |feature|
  feature.engine = Decidim::Results::ListEngine
  feature.admin_engine = Decidim::Results::AdminEngine
  feature.icon = "decidim/results/icon.svg"

  feature.on(:before_destroy) do |instance|
    raise StandardError, "Can't remove this feature" if Decidim::Results::Result.where(feature: instance).any?
  end

  feature.seeds do
    Decidim::ParticipatoryProcess.all.each do |process|
      next unless process.steps.any?

      feature = Decidim::Feature.create!(
        name: Decidim::Features::Namer.new(process.organization.available_locales, :results).i18n_name,
        manifest_name: :results,
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
          end,
          short_description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
            Decidim::Faker::Localized.paragraph(3)
          end
        )

        Decidim::Comments::Seed.comments_for(result)
      end
    end
  end
end
