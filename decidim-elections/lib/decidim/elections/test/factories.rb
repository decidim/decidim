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

    published_at { nil }
    deleted_at { nil }

    trait :real_time do
      results_availability { "real_time" }
    end

    trait :per_question do
      results_availability { "per_question" }
    end

    trait :after_end do
      results_availability { "after_end" }
    end

    trait :scheduled do
      start_at { 1.day.from_now }
      end_at { 2.days.from_now }
    end

    trait :started do
      start_at { 1.day.ago }
      end_at { 1.day.from_now }
    end

    trait :ongoing do
      start_at { 1.day.ago }
      end_at { 1.day.from_now }
    end

    trait :finished do
      start_at { 30.days.ago }
      end_at { 1.day.ago }
    end

    trait :published do
      published_at { Time.current }
    end

    trait :results_published do
      published_results_at { Time.current }
    end

    trait :with_questions do
      after :create do |election, _evaluator|
        create_list(:election_question, 2, election:)
      end
    end

    trait :with_image do
      after :create do |election, evaluator|
        election.attachments << create(:attachment, :with_image, attached_to: election, skip_injection: evaluator.skip_injection)
      end
    end

    trait :with_internal_users_census do
      census_manifest { "internal_users" }
      census_settings { { "verification_handlers" => ["postal_letter"] } }
    end

    trait :with_token_csv_census do
      census_manifest { "token_csv" }

      after :create do |election|
        create_list(:voter, 3, election:)
      end
    end
  end

  factory :election_question, class: "Decidim::Elections::Question" do
    association :election
    body { generate_localized_title(:question_body) }
    description { generate_localized_description(:question_description) }
    mandatory { false }
    question_type { "multiple_option" }
    sequence(:position) { |n| n }

    trait :published_results do
      published_results_at { Time.current }
    end

    transient do
      with_response_options { true }
    end

    transient do
      voting_enabled { true }
    end

    voting_enabled_at { voting_enabled ? Time.current : nil }

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
