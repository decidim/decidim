# frozen_string_literal: true

require "decidim/pages/seeds"

Decidim.register_component(:pages) do |component|
  component.engine = Decidim::Pages::Engine
  component.admin_engine = Decidim::Pages::AdminEngine
  component.icon = "media/images/decidim_pages.svg"
  component.icon_key = "pages-line"
  component.serializes_specific_data = true
  component.specific_data_serializer_class_name = "Decidim::Pages::DataSerializer"
  component.specific_data_importer_class_name = "Decidim::Pages::DataImporter"
  component.permissions_class_name = "Decidim::Pages::Permissions"

  component.query_type = "Decidim::Pages::PagesType"

  component.on(:create) do |instance|
    Decidim::Pages::CreatePage.call(instance) do
      on(:invalid) { raise "Cannot create page" }
    end
  end

  component.on(:destroy) do |instance|
    Decidim::Pages::DestroyPage.call(instance) do
      on(:error) { raise "Cannot destroy page" }
    end
  end

  component.on(:copy) do |context|
    Decidim::Pages::CopyPage.call(context) do
      on(:invalid) { raise "Cannot duplicate page" }
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

  component.register_resource(:page) do |resource|
    resource.model_class_name = "Decidim::Pages::Page"
  end

  component.seeds do |participatory_space|
    Decidim::Pages::Seeds.new(participatory_space:).call
  end
end
