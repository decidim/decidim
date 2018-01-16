# frozen_string_literal: true

require_dependency "decidim/features/namer"

Decidim.register_feature(:debates) do |feature|
  feature.engine = Decidim::Debates::Engine
  feature.admin_engine = Decidim::Debates::AdminEngine
  feature.icon = "decidim/debates/icon.svg"

  feature.on(:before_destroy) do |instance|
    raise StandardError, "Can't remove this feature" if Decidim::Debates::Debate.where(feature: instance).any?
  end

  feature.settings(:global) do |settings|
    settings.attribute :comments_enabled, type: :boolean, default: true
  end

  feature.settings(:step) do |settings|
    settings.attribute :comments_blocked, type: :boolean, default: false
  end

  feature.register_resource do |resource|
    resource.model_class_name = "Decidim::Debates::Debate"
  end

  feature.seeds do
    Decidim::ParticipatoryProcess.all.each do |process|
      next unless process.steps.any?

      feature = Decidim::Feature.create!(
        name: Decidim::Features::Namer.new(process.organization.available_locales, :debates).i18n_name,
        manifest_name: :debates,
        participatory_space: process
      )

      3.times do
        debate = Decidim::Debates::Debate.create!(
          feature: feature,
          category: process.categories.sample,
          title: Decidim::Faker::Localized.sentence(2),
          description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
            Decidim::Faker::Localized.paragraph(3)
          end,
          instructions: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
            Decidim::Faker::Localized.paragraph(3)
          end,
          start_time: 3.weeks.from_now,
          end_time: 3.weeks.from_now + 4.hours
        )

        Decidim::Comments::Seed.comments_for(debate)
      end
    end
  end
end
