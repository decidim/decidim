require "decidim/core/test/factories"
require "decidim/comments/test/factories"

FactoryGirl.define do
  factory :page_feature, parent: :feature do
    name { Decidim::Features::Namer.new(participatory_process.organization.available_locales, :pages).i18n_name }
    manifest_name :pages
    participatory_process { create(:participatory_process, :with_steps) }
  end

  factory :page, class: Decidim::Pages::Page do
    body { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(4) } }
    feature { build(:feature, manifest_name: "pages") }
  end
end
