# frozen_string_literal: true

require "decidim/faker/localized"
require "decidim/dev"

require "decidim/core/test/factories"
require "decidim/participatory_processes/test/factories"

FactoryBot.define do
  factory :accountability_component, parent: :component do
    name { Decidim::Components::Namer.new(participatory_space.organization.available_locales, :accountability).i18n_name }
    manifest_name { :accountability }
    participatory_space { create(:participatory_process, :with_steps, organization: organization) }
    settings do
      {
        intro: Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title },
        categories_label: Decidim::Faker::Localized.word,
        subcategories_label: Decidim::Faker::Localized.word,
        heading_parent_level_results: Decidim::Faker::Localized.word,
        heading_leaf_level_results: Decidim::Faker::Localized.word,
        scopes_enabled: true,
        scope_id: participatory_space.scope&.id
      }
    end
  end

  factory :status, class: "Decidim::Accountability::Status" do
    component { create(:accountability_component) }
    sequence(:key) { |n| "status_#{n}" }
    name { Decidim::Faker::Localized.word }
    description { generate_localized_title }
    progress { rand(1..100) }
  end

  factory :result, class: "Decidim::Accountability::Result" do
    component { create(:accountability_component) }
    title { generate_localized_title }
    description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title } }
    start_date { "12/7/2017" }
    end_date { "30/9/2017" }
    status { create :status, component: component }
    progress { rand(1..100) }
  end

  factory :timeline_entry, class: "Decidim::Accountability::TimelineEntry" do
    result { create(:result) }
    entry_date { "12/7/2017" }
    title { generate_localized_title }
    description { generate_localized_title }
  end
end
