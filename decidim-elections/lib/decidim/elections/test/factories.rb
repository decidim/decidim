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
        election.questions << build(:question, :yes_no, election: election, weight: 1)
        election.questions << build(:question, :candidates, election: election, weight: 3)
        election.questions << build(:question, :projects, election: election, weight: 2)
      end
    end
  end

  factory :question, class: "Decidim::Elections::Question" do
    transient do
      complete { false }
      more_information { false }
      answers { 3 }
    end

    election
    title { generate_localized_title }
    description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title } }
    max_selections { 1 }
    weight { Faker::Number.number(1) }
    random_answers_order { true }

    trait :yes_no do
      complete { true }
      random_answers_order { false }
    end

    trait :candidates do
      complete { true }
      max_selections { 6 }
      answers { 10 }
    end

    trait :projects do
      complete { true }
      max_selections { 3 }
      answers { 6 }
      more_information { true }
    end

    trait :complete do
      complete { true }
    end

    after(:build) do |question, evaluator|
      if evaluator.complete
        overrides = { question: question }
        overrides[:description] = nil unless evaluator.more_information
        question.answers = build_list(:election_answer, evaluator.answers, overrides)
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
