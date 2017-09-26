# frozen_string_literal: true

require_dependency "decidim/features/namer"

Decidim.register_feature(:accountability) do |feature|
  feature.engine = Decidim::Accountability::ListEngine
  feature.admin_engine = Decidim::Accountability::AdminEngine
  feature.icon = "decidim/accountability/icon.svg"
  feature.stylesheet = "decidim/accountability/accountability"

  feature.on(:before_destroy) do |instance|
    raise StandardError, "Can't remove this feature" if Decidim::Accountability::Result.where(feature: instance).any?
  end

  feature.register_resource do |resource|
    resource.model_class_name = "Decidim::Accountability::Result"
    resource.template = "decidim/accountability/results/linked_results"
  end

  feature.settings(:global) do |settings|
    settings.attribute :comments_enabled, type: :boolean, default: true
  end

  feature.settings(:step) do |settings|
    settings.attribute :comments_blocked, type: :boolean, default: false
  end

  feature.seeds do |participatory_space|
    feature = Decidim::Feature.create!(
      name: Decidim::Features::Namer.new(participatory_space.organization.available_locales, :accountability).i18n_name,
      manifest_name: :accountability,
      published_at: Time.current,
      participatory_space: participatory_space
    )

    5.times do |i|
      Decidim::Accountability::Status.create!(
        feature: feature,
        name: Decidim::Faker::Localized.word,
        key: "status_#{i}"
      )
    end

    3.times do
      result = Decidim::Accountability::Result.create!(
        feature: feature,
        scope: participatory_space.organization.scopes.sample,
        category: participatory_space.categories.sample,
        title: Decidim::Faker::Localized.sentence(2),
        description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
          Decidim::Faker::Localized.paragraph(3)
        end
      )

      Decidim::Comments::Seed.comments_for(result)

      3.times do
        child_result = Decidim::Accountability::Result.create!(
          feature: feature,
          parent: result,
          start_date: Time.zone.today,
          end_date: Time.zone.today + 10,
          status: Decidim::Accountability::Status.all.sample,
          progress: rand(1..100),
          title: Decidim::Faker::Localized.sentence(2),
          description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
            Decidim::Faker::Localized.paragraph(3)
          end
        )

        rand(0..5).times do |i|
          child_result.timeline_entries.create!(
            entry_date: child_result.start_date + i.days,
            description: Decidim::Faker::Localized.sentence(2)
          )
        end

        Decidim::Comments::Seed.comments_for(child_result)
      end
    end
  end
end
