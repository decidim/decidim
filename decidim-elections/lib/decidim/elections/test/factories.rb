# frozen_string_literal: true

require "decidim/core/test/factories"

FactoryBot.define do
  factory :elections_component, parent: :component do
    name { Decidim::Components::Namer.new(participatory_space.organization.available_locales, :elections).i18n_name }
    manifest_name { :elections }
    participatory_space { create(:participatory_process, :with_steps) }
  end

  factory :election, class: "Decidim::Elections::Election" do
    title { generate_localized_title }
    subtitle { Decidim::Faker::Localized.sentence(3) }
    description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title } }
    start_time { 1.day.from_now }
    end_time { 3.days.from_now }
    component { create(:elections_component) }

    trait :started do
      start_time { 1.day.ago }
    end
  end
end
