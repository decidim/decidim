# frozen_string_literal: true

require "decidim/faker/localized"
require "decidim/dev"

FactoryGirl.define do
  factory :accountability_feature, parent: :feature do
    name { Decidim::Features::Namer.new(participatory_space.organization.available_locales, :accountability).i18n_name }
    manifest_name :accountability
    participatory_space { create(:participatory_process, :with_steps, organization: organization) }
  end

  factory :accountability_template_texts, class: Decidim::Accountability::TemplateTexts do
    feature { build(:feature, manifest_name: "accountability") }
    intro { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(4) } }
    categories_label { Decidim::Faker::Localized.word }
    subcategories_label { Decidim::Faker::Localized.word }
    heading_parent_level_results { Decidim::Faker::Localized.word }
    heading_leaf_level_results { Decidim::Faker::Localized.word }
  end

  factory :accountability_status, class: Decidim::Accountability::Status do
    feature { build(:feature, manifest_name: "accountability") }
    sequence(:key) { |n| "status_#{n}" }
    name { Decidim::Faker::Localized.word }
    description { Decidim::Faker::Localized.sentence(3) }
    progress { rand(1..100) }
  end

  factory :accountability_result, class: Decidim::Accountability::Result do
    feature { build(:feature, manifest_name: "accountability") }
    title { Decidim::Faker::Localized.sentence(3) }
    description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(4) } }
    start_date { "12/7/2017" }
    end_date { "30/9/2017" }
    status { create :accountability_status, feature: feature }
    progress { rand(1..100) }
  end

  factory :accountability_timeline_entry, class: Decidim::Accountability::TimelineEntry do
    result { build(:accountability_result) }
    entry_date { "12/7/2017" }
    description { Decidim::Faker::Localized.sentence(2) }
  end
end
