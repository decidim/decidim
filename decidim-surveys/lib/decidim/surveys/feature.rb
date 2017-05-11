# frozen_string_literal: true

require_dependency "decidim/features/namer"

Decidim.register_feature(:surveys) do |feature|
  feature.engine = Decidim::Surveys::Engine
  feature.admin_engine = Decidim::Surveys::AdminEngine
  feature.icon = "decidim/surveys/icon.svg"

  feature.on(:create) do |instance|
    Decidim::Surveys::CreateSurvey.call(instance) do
      on(:invalid) { raise "Can't create survey" }
    end
  end

  feature.on(:destroy) do |instance|
    Decidim::Surveys::DestroySurvey.call(instance) do
      on(:error) { raise "Can't destroy survey" }
    end
  end

  # These actions permissions can be configured in the admin panel
  # feature.actions = %w()

  # feature.settings(:global) do |settings|
  #   # Add your global settings
  #   # Available types: :integer, :boolean
  #   # settings.attribute :vote_limit, type: :integer, default: 0
  # end

  # feature.settings(:step) do |settings|
  #   # Add your settings per step
  # end

  # feature.register_resource do |resource|
  #   # Register a optional resource that can be references from other resources.
  #   resource.model_class_name = "Decidim::Surveys::SomeResource"
  #   resource.template = "decidim/surveys/some_resources/linked_some_resources"
  # end

  # feature.register_stat :some_stat do |context, start_at, end_at|
  #   # Register some stat number to the application
  # end

  feature.seeds do
    Decidim::ParticipatoryProcess.all.each do |process|
      next unless process.steps.any?

      feature = Decidim::Feature.create!(
        name: Decidim::Features::Namer.new(process.organization.available_locales, :surveys).i18n_name,
        manifest_name: :surveys,
        published_at: Time.current,
        participatory_process: process
      )

      Decidim::Surveys::Survey.create!(
        feature: feature,
        title: Decidim::Faker::Localized.paragraph,
        description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
          Decidim::Faker::Localized.paragraph(3)
        end,
        toc: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
          Decidim::Faker::Localized.paragraph(2)
        end
      )
    end
  end
end
