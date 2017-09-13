# frozen_string_literal: true

require "decidim/features/namer"

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

  feature.on(:copy) do |context|
    Decidim::Pages::CopyPage.call(context) do
      on(:invalid) { raise "Can't duplicate page" }
    end
  end

  feature.register_stat :pages_count do |features, start_at, end_at|
    pages = Decidim::Pages::Page.where(feature: features)
    pages = pages.where("created_at >= ?", start_at) if start_at.present?
    pages = pages.where("created_at <= ?", end_at) if end_at.present?
    pages.count
  end

  feature.settings(:global) do |settings|
    settings.attribute :announcement, type: :text, translated: true, editor: true
  end

  feature.settings(:step) do |settings|
    settings.attribute :announcement, type: :text, translated: true, editor: true
  end

  feature.register_resource do |resource|
    resource.model_class_name = "Decidim::Pages::Page"
  end

  feature.seeds do |participatory_space|
    feature = Decidim::Feature.create!(
      name: Decidim::Features::Namer.new(participatory_space.organization.available_locales, :pages).i18n_name,
      manifest_name: :pages,
      published_at: Time.current,
      participatory_space: participatory_space
    )

    Decidim::Pages::Page.create!(
      feature: feature,
      body: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
        Decidim::Faker::Localized.paragraph(3)
      end
    )
  end
end
