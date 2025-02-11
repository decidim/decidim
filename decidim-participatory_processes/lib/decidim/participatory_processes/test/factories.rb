# frozen_string_literal: true

require "decidim/faker/localized"
require "decidim/dev"

require "decidim/core/test/factories"

FactoryBot.define do
  sequence(:participatory_process_slug) do |n|
    "#{Decidim::Faker::Internet.slug(words: nil, glue: "-")}-#{n}"
  end

  factory :participatory_process, class: "Decidim::ParticipatoryProcess" do
    transient do
      skip_injection { false }
    end
    title { generate_localized_title(:participatory_process_title, skip_injection:) }
    slug { generate(:participatory_process_slug) }
    subtitle { generate_localized_title(:participatory_process_subtitle, skip_injection:) }
    weight { 1 }
    short_description { generate_localized_description(:participatory_process_short_description, skip_injection:) }
    description { generate_localized_description(:participatory_process_description, skip_injection:) }
    organization
    hero_image { Decidim::Dev.test_file("city.jpeg", "image/jpeg") } # Keep after organization
    published_at { Time.current }
    deleted_at { nil }
    meta_scope { generate_localized_word(:participatory_process_meta_scope, skip_injection:) }
    developer_group { generate_localized_title(:participatory_process_developer_group, skip_injection:) }
    local_area { generate_localized_title(:participatory_process_local_area, skip_injection:) }
    target { generate_localized_title(:participatory_process_target, skip_injection:) }
    participatory_scope { generate_localized_title(:participatory_process_participatory_scope, skip_injection:) }
    participatory_structure { generate_localized_title(:participatory_process_participatory_structure, skip_injection:) }
    announcement { generate_localized_title(:participatory_process_announcement, skip_injection:) }
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

    trait :trashed do
      deleted_at { Time.current }
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
               skip_injection: evaluator.skip_injection,
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

    trait :with_content_blocks do
      transient { blocks_manifests { [:hero] } }

      after(:create) do |participatory_process, evaluator|
        evaluator.blocks_manifests.each do |manifest_name|
          create(
            :content_block,
            organization: participatory_process.organization,
            scope_name: :participatory_process_homepage,
            manifest_name:,
            skip_injection: evaluator.skip_injection,
            scoped_resource_id: participatory_process.id
          )
        end
      end
    end
  end

  factory :participatory_process_group, class: "Decidim::ParticipatoryProcessGroup" do
    transient do
      skip_injection { false }
    end
    title { generate_localized_title(:participatory_process_group_title, skip_injection:) }
    description { generate_localized_description(:participatory_process_group_description, skip_injection:) }
    hero_image { Decidim::Dev.test_file("city.jpeg", "image/jpeg") }
    organization
    hashtag { Faker::Internet.slug }
    group_url { Faker::Internet.url }
    developer_group { generate_localized_title(:participatory_process_group_developer_group, skip_injection:) }
    local_area { generate_localized_title(:participatory_process_group_local_area, skip_injection:) }
    meta_scope { Decidim::Faker::Localized.word }
    target { generate_localized_title(:participatory_process_group_target, skip_injection:) }
    participatory_scope { generate_localized_title(:participatory_process_group_participatory_scope, skip_injection:) }
    participatory_structure { generate_localized_title(:participatory_process_group_participatory_structure, skip_injection:) }

    trait :promoted do
      promoted { true }
    end

    trait :with_participatory_processes do
      after(:create) do |participatory_process_group, evaluator|
        create_list(:participatory_process, 2, :published, organization: participatory_process_group.organization, participatory_process_group:,
                                                           skip_injection: evaluator.skip_injection)
      end
    end
  end

  factory :participatory_process_step, class: "Decidim::ParticipatoryProcessStep" do
    transient do
      skip_injection { false }
    end
    title { generate_localized_title(:participatory_process_step_title, skip_injection:) }
    description { generate_localized_description(:participatory_process_step_description, skip_injection:) }
    cta_text { generate_localized_description(:participatory_process_step_cta_text, skip_injection:) }
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
    transient do
      skip_injection { false }
    end
    title { generate_localized_title(:participatory_process_type_title, skip_injection:) }
    organization

    trait :with_active_participatory_processes do
      after(:create) do |participatory_process_type, evaluator|
        create_list(:participatory_process, 2, :active, :published, organization: participatory_process_type.organization, participatory_process_type:,
                                                                    skip_injection: evaluator.skip_injection)
      end
    end

    trait :with_past_participatory_processes do
      after(:create) do |participatory_process_type, evaluator|
        create_list(:participatory_process, 2, :past, :published, organization: participatory_process_type.organization, participatory_process_type:,
                                                                  skip_injection: evaluator.skip_injection)
      end
    end
  end

  factory :process_admin, parent: :user, class: "Decidim::User" do
    transient do
      skip_injection { false }
      participatory_process { create(:participatory_process, skip_injection:) }
    end

    organization { participatory_process.organization }
    admin_terms_accepted_at { Time.current }

    after(:create) do |user, evaluator|
      create(:participatory_process_user_role,
             user:,
             participatory_process: evaluator.participatory_process,
             role: :admin, skip_injection: evaluator.skip_injection)
    end
  end

  factory :process_collaborator, parent: :user, class: "Decidim::User" do
    transient do
      skip_injection { false }
      participatory_process { create(:participatory_process, skip_injection:) }
    end

    organization { participatory_process.organization }
    admin_terms_accepted_at { Time.current }

    after(:create) do |user, evaluator|
      create(:participatory_process_user_role,
             user:,
             participatory_process: evaluator.participatory_process,
             role: :collaborator, skip_injection: evaluator.skip_injection)
    end
  end

  factory :process_moderator, parent: :user, class: "Decidim::User" do
    transient do
      skip_injection { false }
      participatory_process { create(:participatory_process, skip_injection:) }
    end

    organization { participatory_process.organization }
    admin_terms_accepted_at { Time.current }

    after(:create) do |user, evaluator|
      create(:participatory_process_user_role,
             user:,
             participatory_process: evaluator.participatory_process,
             role: :moderator, skip_injection: evaluator.skip_injection)
    end
  end

  factory :process_evaluator, parent: :user, class: "Decidim::User" do
    transient do
      skip_injection { false }
      participatory_process { create(:participatory_process, skip_injection:) }
    end

    organization { participatory_process.organization }
    admin_terms_accepted_at { Time.current }

    after(:create) do |user, evaluator|
      create(:participatory_process_user_role,
             user:,
             participatory_process: evaluator.participatory_process,
             role: :evaluator, skip_injection: evaluator.skip_injection)
    end
  end

  factory :participatory_process_user_role, class: "Decidim::ParticipatoryProcessUserRole" do
    transient do
      skip_injection { false }
    end
    user
    participatory_process { create(:participatory_process, organization: user.organization, skip_injection:) }
    role { "admin" }
  end
end
