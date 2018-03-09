# frozen_string_literal: true

require "decidim/components/namer"

Decidim.register_component(:pages) do |component|
  component.engine = Decidim::Pages::Engine
  component.admin_engine = Decidim::Pages::AdminEngine
  component.icon = "decidim/pages/icon.svg"

  component.on(:create) do |instance|
    Decidim::Pages::CreatePage.call(instance) do
      on(:invalid) { raise "Can't create page" }
    end
  end

  component.on(:destroy) do |instance|
    Decidim::Pages::DestroyPage.call(instance) do
      on(:error) { raise "Can't destroy page" }
    end
  end

  component.on(:copy) do |context|
    Decidim::Pages::CopyPage.call(context) do
      on(:invalid) { raise "Can't duplicate page" }
    end
  end

  component.register_stat :pages_count do |components, start_at, end_at|
    pages = Decidim::Pages::Page.where(component: components)
    pages = pages.where("created_at >= ?", start_at) if start_at.present?
    pages = pages.where("created_at <= ?", end_at) if end_at.present?
    pages.count
  end

  component.settings(:global) do |settings|
    settings.attribute :announcement, type: :text, translated: true, editor: true
  end

  component.settings(:step) do |settings|
    settings.attribute :announcement, type: :text, translated: true, editor: true
  end

  component.register_resource do |resource|
    resource.model_class_name = "Decidim::Pages::Page"
  end

  component.seeds do |participatory_space|
    component = Decidim::Component.create!(
      name: Decidim::Components::Namer.new(participatory_space.organization.available_locales, :pages).i18n_name,
      manifest_name: :pages,
      published_at: Time.current,
      participatory_space: participatory_space
    )

    Decidim::Pages::Page.create!(
      component: component,
      body: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
        Decidim::Faker::Localized.paragraph(3)
      end
    )
  end
end
