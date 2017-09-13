# frozen_string_literal: true

require "decidim/core/test/factories"
require "decidim/participatory_processes/test/factories"

FactoryGirl.define do
  factory :page_feature, parent: :feature do
    name { Decidim::Features::Namer.new(participatory_space.organization.available_locales, :pages).i18n_name }
    manifest_name :pages
    participatory_space { create(:participatory_process, :with_steps, organization: organization) }
  end

  factory :page, class: Decidim::Pages::Page do
    body { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(4) } }
    feature { build(:feature, manifest_name: "pages") }
  end
end
