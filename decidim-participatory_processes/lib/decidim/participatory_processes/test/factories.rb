# frozen_string_literal: true

require "decidim/faker/localized"
require "decidim/dev"

require "decidim/core/test/factories"

FactoryBot.define do
  sequence(:participatory_process_slug) do |n|
    "#{Decidim::Faker::Internet.slug(words: nil, glue: "-")}-#{n}"
  end

  factory :participatory_process, class: "Decidim::ParticipatoryProcess" do
    title { generate_localized_title }
    slug { generate(:participatory_process_slug) }
    subtitle { generate_localized_title }
    weight { 1 }
    short_description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title } }
    description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title } }
    organization
    hero_image { Decidim::Dev.test_file("city.jpeg", "image/jpeg") } # Keep after organization
    banner_image { Decidim::Dev.test_file("city2.jpeg", "image/jpeg") } # Keep after organization
    published_at { Time.current }
    meta_scope { Decidim::Faker::Localized.word }
    developer_group { generate_localized_title }
    local_area { generate_localized_title }
    target { generate_localized_title }
    participatory_scope { generate_localized_title }
    participatory_structure { generate_localized_title }
    announcement { generate_localized_title }
    show_metrics { true }
    show_statistics { true }
    private_space { false }
    start_date { Date.current }
    end_date { 2.months.from_now }
    area { nil }

    trait :promoted do
      promoted { true }
    end

    trait :unpublished do
      published_at { nil }
    end

    trait :published do
      published_at { Time.current }
    end

    trait :private do
      private_space { true }
    end

    trait :with_steps do
      transient { current_step_ends { 1.month.from_now } }

      after(:create) do |participatory_process, evaluator|
        create(:participatory_process_step,
               active: true,
               end_date: evaluator.current_step_ends,
               participatory_process:)
        participatory_process.reload
        participatory_process.steps.reload
      end
    end

    trait :active do
      start_date { 2.weeks.ago }
      end_date { 1.week.from_now }
    end

    trait :past do
      start_date { 2.weeks.ago }
      end_date { 1.week.ago }
    end

    trait :upcoming do
      start_date { 1.week.from_now }
      end_date { 2.weeks.from_now }
    end

    trait :with_scope do
      scopes_enabled { true }
      scope { create :scope, organization: }
    end
  end

  factory :participatory_process_group, class: "Decidim::ParticipatoryProcessGroup" do
    title { generate_localized_title }
    description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title } }
    hero_image { Decidim::Dev.test_file("city.jpeg", "image/jpeg") }
    organization
    hashtag { Faker::Internet.slug }
    group_url { Faker::Internet.url }
    developer_group { generate_localized_title }
    local_area { generate_localized_title }
    meta_scope { Decidim::Faker::Localized.word }
    target { generate_localized_title }
    participatory_scope { generate_localized_title }
    participatory_structure { generate_localized_title }

    trait :promoted do
      promoted { true }
    end

    trait :with_participatory_processes do
      after(:create) do |participatory_process_group|
        create_list(:participatory_process, 2, :published, organization: participatory_process_group.organization, participatory_process_group:)
      end
    end
  end

  factory :participatory_process_step, class: "Decidim::ParticipatoryProcessStep" do
    title { generate_localized_title }
    description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title } }
    start_date { 1.month.ago }
    end_date { 2.months.from_now }
    position { nil }
    participatory_process

    after(:create) do |step, _evaluator|
      step.participatory_process.reload
      step.participatory_process.steps.reload
    end

    trait :active do
      active { true }
    end
  end

  factory :participatory_process_type, class: "Decidim::ParticipatoryProcessType" do
    title { generate_localized_title }
    organization

    trait :with_active_participatory_processes do
      after(:create) do |participatory_process_type|
        create_list(:participatory_process, 2, :active, :published, organization: participatory_process_type.organization, participatory_process_type:)
      end
    end

    trait :with_past_participatory_processes do
      after(:create) do |participatory_process_type|
        create_list(:participatory_process, 2, :past, :published, organization: participatory_process_type.organization, participatory_process_type:)
      end
    end
  end

  factory :process_admin, parent: :user, class: "Decidim::User" do
    transient do
      participatory_process { create(:participatory_process) }
    end

    organization { participatory_process.organization }

    after(:create) do |user, evaluator|
      create :participatory_process_user_role,
             user:,
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
             user:,
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
             user:,
             participatory_process: evaluator.participatory_process,
             role: :moderator
    end
  end

  factory :process_valuator, parent: :user, class: "Decidim::User" do
    transient do
      participatory_process { create(:participatory_process) }
    end

    organization { participatory_process.organization }

    after(:create) do |user, evaluator|
      create :participatory_process_user_role,
             user:,
             participatory_process: evaluator.participatory_process,
             role: :valuator
    end
  end

  factory :participatory_process_user_role, class: "Decidim::ParticipatoryProcessUserRole" do
    user
    participatory_process { create :participatory_process, organization: user.organization }
    role { "admin" }
  end
end
