# frozen_string_literal: true

require "decidim/faker/localized"
require "decidim/dev"

FactoryGirl.define do
  sequence(:participatory_process_slug) do |n|
    "#{Faker::Internet.slug(nil, "-")}-#{n}"
  end

  factory :participatory_process, class: Decidim::ParticipatoryProcess do
    title { Decidim::Faker::Localized.sentence(3) }
    slug { generate(:participatory_process_slug) }
    subtitle { Decidim::Faker::Localized.sentence(1) }
    short_description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(2) } }
    description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(4) } }
    hero_image { Decidim::Dev.test_file("city.jpeg", "image/jpeg") }
    banner_image { Decidim::Dev.test_file("city2.jpeg", "image/jpeg") }
    published_at { Time.current }
    organization
    meta_scope { Decidim::Faker::Localized.word }
    developer_group { Decidim::Faker::Localized.sentence(1) }
    local_area { Decidim::Faker::Localized.sentence(2) }
    target { Decidim::Faker::Localized.sentence(3) }
    participatory_scope { Decidim::Faker::Localized.sentence(1) }
    participatory_structure { Decidim::Faker::Localized.sentence(2) }
    end_date 2.month.from_now.at_midnight
    show_statistics true
    starts_at { Time.current }

    trait :promoted do
      promoted true
    end

    trait :unpublished do
      published_at nil
    end

    trait :published do
      published_at { Time.current }
    end

    trait :with_steps do
      transient { current_step_ends 1.month.from_now }

      after(:create) do |participatory_process, evaluator|
        create(:participatory_process_step,
               active: true,
               end_date: evaluator.current_step_ends,
               participatory_process: participatory_process)
        participatory_process.reload
        participatory_process.steps.reload
      end
    end

    trait :past do
      starts_at { 2.weeks.ago }
      ends_at { 1.week.ago }
    end

    trait :upcoming do
      starts_at { 1.week.from_now }
      ends_at { 2.weeks.from_now }
    end
  end

  factory :participatory_process_group, class: Decidim::ParticipatoryProcessGroup do
    name { Decidim::Faker::Localized.sentence(3) }
    description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(4) } }
    hero_image { Decidim::Dev.test_file("city.jpeg", "image/jpeg") }
    organization
  end

  factory :participatory_process_step, class: Decidim::ParticipatoryProcessStep do
    title { Decidim::Faker::Localized.sentence(3) }
    description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(4) } }
    start_date 1.month.ago.at_midnight
    end_date 2.month.from_now.at_midnight
    position nil
    participatory_process

    after(:create) do |step, _evaluator|
      step.participatory_process.reload
      step.participatory_process.steps.reload
    end

    trait :active do
      active true
    end
  end
end
