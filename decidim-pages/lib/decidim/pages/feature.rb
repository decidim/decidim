# frozen_string_literal: true

require_dependency "decidim/features/namer"

Decidim.register_feature(:pages) do |feature|
  feature.engine = Decidim::Pages::Engine
  feature.admin_engine = Decidim::Pages::AdminEngine
  feature.icon = "decidim/pages/icon.svg"

  feature.on(:create) do |instance|
    Decidim::Pages::CreatePage.call(instance) do
      on(:invalid) { raise "Can't create page" }
    end
  end

  feature.on(:destroy) do |instance|
    Decidim::Pages::DestroyPage.call(instance) do
      on(:error) { raise "Can't destroy page" }
    end
  end

  feature.settings(:global) do |settings|
    settings.attribute :comments_enabled, type: :boolean, default: true
  end

  feature.settings(:step) do |settings|
    settings.attribute :comments_blocked, type: :boolean, default: false
  end

  feature.register_resource do |resource|
    resource.model_class_name = "Decidim::Pages::Page"
  end

  feature.seeds do
    Decidim::ParticipatoryProcess.all.each do |process|
      next unless process.steps.any?

      feature = Decidim::Feature.create!(
        name: Decidim::Features::Namer.new(process.organization.available_locales, :pages).i18n_name,
        manifest_name: :pages,
        published_at: Time.current,
        participatory_process: process
      )

      page = Decidim::Pages::Page.create!(
        feature: feature,
        body: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
          Decidim::Faker::Localized.paragraph(3)
        end
      )

      Decidim::Comments::Seed.comments_for(page)
    end
  end
end
