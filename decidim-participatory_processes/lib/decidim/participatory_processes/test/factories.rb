# frozen_string_literal: true

require "decidim/faker/localized"
require "decidim/dev"

require "decidim/core/test/factories"

FactoryBot.define do
  sequence(:participatory_process_slug) do |n|
    "#{Faker::Internet.slug(nil, "-")}-#{n}"
  end

  factory :participatory_process, class: "Decidim::ParticipatoryProcess" do
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
    show_statistics true
    private_space false
    start_date { Time.current }
    end_date { 2.months.from_now.at_midnight }

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
      start_date { 2.weeks.ago }
      end_date { 1.week.ago }
    end

    trait :upcoming do
      start_date { 1.week.from_now }
      end_date { 2.weeks.from_now }
    end
  end

  factory :participatory_process_group, class: "Decidim::ParticipatoryProcessGroup" do
    name { Decidim::Faker::Localized.sentence(3) }
    description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(4) } }
    hero_image { Decidim::Dev.test_file("city.jpeg", "image/jpeg") }
    organization

    trait :with_participatory_processes do
      after(:create) do |participatory_process_group|
        create_list(:participatory_process, 2, :published, organization: participatory_process_group.organization, participatory_process_group: participatory_process_group)
      end
    end
  end

  factory :participatory_process_step, class: "Decidim::ParticipatoryProcessStep" do
    title { Decidim::Faker::Localized.sentence(3) }
    description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(4) } }
    start_date { 1.month.ago.at_midnight }
    end_date { 2.months.from_now.at_midnight }
    position nil
    participatory_process

    after(:create) do |step, _evaluator|
      step.participatory_process.reload
      step.participatory_process.steps.reload
    end

    trait :active do
      active true
    end

    trait :action_btn do
      action_btn_text { Decidim::Faker::Localized.word }
    end
  end

  factory :process_admin, parent: :user, class: "Decidim::User" do
    transient do
      participatory_process { create(:participatory_process) }
    end

    organization { participatory_process.organization }

    after(:create) do |user, evaluator|
      create :participatory_process_user_role,
             user: user,
             participatory_process: evaluator.participatory_process,
             role: :admin
    end
  end

  factory :process_collaborator, parent: :user, class: "Decidim::User" do
    transient do
      participatory_process { create(:participatory_process) }
    end

    organization { participatory_process.organization }

    after(:create) do |user, evaluator|
      create :participatory_process_user_role,
             user: user,
             participatory_process: evaluator.participatory_process,
             role: :collaborator
    end
  end

  factory :process_moderator, parent: :user, class: "Decidim::User" do
    transient do
      participatory_process { create(:participatory_process) }
    end

    organization { participatory_process.organization }

    after(:create) do |user, evaluator|
      create :participatory_process_user_role,
             user: user,
             participatory_process: evaluator.participatory_process,
             role: :moderator
    end
  end

  factory :participatory_process_user_role, class: "Decidim::ParticipatoryProcessUserRole" do
    user
    participatory_process { create :participatory_process, organization: user.organization }
    role "admin"
  end
end
