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
    end_at { 2.days.from_now }

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

    trait :ongoing do
      start_at { 1.day.ago }
      end_at { 1.day.from_now }
    end

    trait :finished do
      start_at { 2.days.ago }
      end_at { 1.day.ago }
    end

    trait :published do
      published_at { Time.current }
    end

    trait :published_results do
      published_at { 2.days.ago }
      start_at { 2.days.ago }
      end_at { 1.day.ago }
      published_results_at { Time.current }
    end

    trait :with_questions do
      after :create do |election, _evaluator|
        create_list(:election_question, 2, :with_response_options, :voting_enabled, election:)
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
        create_list(:election_voter, 3, election:)
      end
    end
  end

  factory :election_question, class: "Decidim::Elections::Question" do
    association :election
    body { generate_localized_title(:question_body) }
    description { generate_localized_description(:question_description) }
    question_type { "multiple_option" }
    sequence(:position) { |n| n }
    published_results_at { nil }
    voting_enabled_at { nil }

    trait :published_results do
      published_results_at { Time.current }
    end

    trait :voting_enabled do
      voting_enabled_at { Time.current }
    end

    trait :with_response_options do
      after :create do |question, _evaluator|
        create_list(:election_response_option, 2, question:)
      end
    end
  end

  factory :election_response_option, class: "Decidim::Elections::ResponseOption" do
    association :question, factory: :election_question
    body { generate_localized_title(:response_option_body) }

    trait :with_votes do
      after :create do |response_option, _evaluator|
        create_list(:election_vote, 2, response_option:, question: response_option.question)
      end
    end
  end

  factory :election_vote, class: "Decidim::Elections::Vote" do
    association :question, factory: :election_question
    association :response_option, factory: :election_response_option
    voter_uid { "voter_#{SecureRandom.hex(4)}" }
  end

  factory :election_voter, class: "Decidim::Elections::Voter" do
    association :election
    sequence(:data) { |n| { email: "voter#{n}@example.com", token: "token#{n}" } }

    trait :with_votes do
      after :create do |voter|
        voter.election.questions.each do |question|
          create(:election_vote, question:, response_option: question.response_options.sample)
        end
      end
    end
  end
end
