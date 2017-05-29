# frozen_string_literal: true

require "decidim/faker/localized"
require "decidim/dev"

FactoryGirl.define do
  factory :result_feature, parent: :feature do
    name { Decidim::Features::Namer.new(participatory_process.organization.available_locales, :results).i18n_name }
    manifest_name :results
    participatory_process { create(:participatory_process, :with_steps) }
  end

  factory :result, class: Decidim::Results::Result do
    title { Decidim::Faker::Localized.sentence(3) }
    description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(4) } }
    feature { build(:feature, manifest_name: "results") }
  end
end
