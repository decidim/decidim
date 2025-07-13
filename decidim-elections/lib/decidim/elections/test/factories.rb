# frozen_string_literal: true

require "decidim/components/namer"
require "decidim/faker/localized"
require "decidim/core/test/factories"
require "decidim/participatory_processes/test/factories"

FactoryBot.define do
  factory :elections_component, parent: :component do
    transient do
      skip_injection { false }
    end

    name { generate_component_name(participatory_space.organization.available_locales, :elections, skip_injection:) }
    manifest_name { :elections }
    participatory_space { create(:participatory_process, :with_steps, skip_injection:, organization:) }
  end

  factory :election, class: "Decidim::Elections::Election" do
    transient do
      skip_injection { false }
    end
    title { generate_localized_title(:election_title, skip_injection:) }
    description { generate_localized_description(:election_description, skip_injection:) }
    start_at { nil }
    end_at { 30.days.from_now }

    component { create(:elections_component, skip_injection:) }

    published_at { Time.current }
    deleted_at { nil }

    trait :unpublished do
      published_at { nil }
    end

    trait :with_image do
      after :create do |election, evaluator|
        election.attachments << create(:attachment, :with_image, attached_to: election, skip_injection: evaluator.skip_injection)
      end
    end
  end

  factory :election_question, class: "Decidim::Elections::Question" do
    association :election
    body { generate_localized_title(:question_body) }
    description { generate_localized_description(:question_description) }
    mandatory { false }
    question_type { "multiple_option" }
    position { 0 }

    transient do
      with_response_options { true }
    end

    after :create do |question, evaluator|
      create_list(:election_response_option, 2, question:) if evaluator.with_response_options
    end
  end

  factory :election_response_option, class: "Decidim::Elections::ResponseOption" do
    association :question, factory: :election_question
    body { generate_localized_title(:response_option_body) }
  end

  factory :voter, class: "Decidim::Elections::Voter" do
    association :election
    sequence(:data) { |n| { email: "voter#{n}@example.com", token: "token#{n}" } }
  end
end
