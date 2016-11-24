# frozen_string_literal: true
Decidim.register_feature(:pages) do |feature|
  feature.component :page do |component|
    component.engine = Decidim::Pages::Engine
    component.admin_engine = Decidim::Pages::AdminEngine

    component.on(:create) do |instance|
      Decidim::Pages::CreatePage.call(instance) do
        on(:error) { raise "Can't create page" }
      end
    end

    component.on(:destroy) do |instance|
      Decidim::Pages::DestroyPage.call(instance) do
        on(:error) { raise "Can't destroy page" }
      end
    end
  end

  feature.seeds do
    Decidim::ParticipatoryProcess.all.each do |process|
      next unless process.steps.any?

      feature = Decidim::Feature.create!(
        name: Decidim::Faker::Localized.sentence(2),
        feature_type: :pages,
        participatory_process: process
      )

      page_component = Decidim::Component.create!(
        name: Decidim::Faker::Localized.sentence(2),
        component_type: :page,
        feature: feature,
        step: process.steps.sample
      )

      Decidim::Pages::Page.create!(
        component: page_component,
        title: Decidim::Faker::Localized.sentence(2),
        body: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
          Decidim::Faker::Localized.paragraph(3)
        end
      )
    end
  end
end
