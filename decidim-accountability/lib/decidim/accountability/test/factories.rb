# frozen_string_literal: true

require "decidim/components/namer"
require "decidim/faker/localized"
require "decidim/dev"

require "decidim/core/test/factories"
require "decidim/participatory_processes/test/factories"

FactoryBot.define do
  factory :accountability_component, parent: :component do
    transient do
      skip_injection { false }
    end
    name { generate_component_name(participatory_space.organization.available_locales, :accountability, skip_injection:) }
    manifest_name { :accountability }
    participatory_space { create(:participatory_process, :with_steps, organization:, skip_injection:) }
    settings do
      {
        intro: generate_localized_description(:accountability_component_intro, skip_injection:)
      }
    end
  end

  factory :status, class: "Decidim::Accountability::Status" do
    transient do
      skip_injection { false }
    end
    component { create(:accountability_component, skip_injection:) }
    sequence(:key) { |n| "status_#{n}" }
    name { generate_localized_word(:status_name, skip_injection:) }
    description { generate_localized_word(:status_description, skip_injection:) }
    progress { rand(1..100) }
  end

  factory :result, class: "Decidim::Accountability::Result" do
    transient do
      skip_injection { false }
    end
    component { create(:accountability_component, skip_injection:) }
    title { generate_localized_title(:result_title, skip_injection:) }
    description { generate_localized_description(:result_description, skip_injection:) }
    start_date { "12/7/2017" }
    end_date { "30/9/2017" }
    status { create(:status, component:, skip_injection:) }
    progress { rand(1..100) }
    deleted_at { nil }
    address { Faker::Lorem.sentence(word_count: 3) }
    latitude { Faker::Address.latitude }
    longitude { Faker::Address.longitude }
  end

  factory :milestone, class: "Decidim::Accountability::MilestoneEntry" do
    transient do
      skip_injection { false }
    end
    result { create(:result, skip_injection:) }
    entry_date { "12/7/2017" }
    title { generate_localized_title(:milestone_title, skip_injection:) }
    description { generate_localized_title(:milestone_description, skip_injection:) }
  end
end
