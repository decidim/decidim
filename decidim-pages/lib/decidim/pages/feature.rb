# frozen_string_literal: true

require_dependency "decidim/features/namer"

Decidim.register_feature(:pages) do |feature|
  feature.engine = Decidim::Pages::Engine
  feature.admin_engine = Decidim::Pages::AdminEngine

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

  feature.seeds do
    Decidim::ParticipatoryProcess.all.each do |process|
      next unless process.steps.any?

      feature = Decidim::Feature.create!(
        name: Decidim::Features::Namer.new(process.organization, :pages).i18n_name,
        manifest_name: :pages,
        participatory_process: process
      )

      Decidim::Pages::Page.create!(
        feature: feature,
        title: Decidim::Faker::Localized.sentence(2),
        body: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
          Decidim::Faker::Localized.paragraph(3)
        end,
        commentable: true
      )
    end
  end
end
