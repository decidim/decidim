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
    start_time { 1.day.ago }
    end_time { 3.days.from_now }
    published_at { nil }
    component { create(:elections_component) }

    trait :started do
    end

    trait :upcoming do
      start_time { 1.day.from_now }
    end

    trait :finished do
      end_time { 1.day.ago }
    end

    trait :published do
      published_at { Time.current }
    end

    trait :complete do
      after(:build) do |election, _evaluator|
        build_list(:question, 2, :complete, election: election)
      end
    end
  end

  factory :question, class: "Decidim::Elections::Question" do
    election
    title { generate_localized_title }
    description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title } }
    max_selections { 1 }
    weight { Faker::Number.number(1) }
    random_answers_order { true }

    trait :complete do
      after(:build) do |question, _evaluator|
        build_list(:election_answer, 2, question: question)
      end
    end
  end

  factory :election_answer, class: "Decidim::Elections::Answer" do
    question
    title { generate_localized_title }
    description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title } }
    weight { Faker::Number.number(1) }
  end
end
