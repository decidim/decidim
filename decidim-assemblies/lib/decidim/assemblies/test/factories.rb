# frozen_string_literal: true

require "decidim/faker/localized"
require "decidim/dev"

FactoryBot.define do
  sequence(:assembly_slug) do |n|
    "#{Decidim::Faker::Internet.slug(words: nil, glue: "-")}-#{n}"
  end

  factory :assemblies_setting, class: "Decidim::AssembliesSetting" do
    enable_organization_chart { true }
    organization
  end

  factory :assemblies_type, class: "Decidim::AssembliesType" do
    transient do
      skip_injection { false }
    end
    title { generate_localized_title(:assemblies_type_title, skip_injection: skip_injection) }
    organization
  end

  factory :assembly, class: "Decidim::Assembly" do
    transient do
      skip_injection { false }
    end
    title { generate_localized_title(:assembly_title, skip_injection: skip_injection) }
    slug { generate(:assembly_slug) }
    subtitle { generate_localized_title(:assembly_subtitle, skip_injection: skip_injection) }
    short_description { generate_localized_description(:assembly_short_description, skip_injection: skip_injection) }
    description { generate_localized_description(:assembly_description, skip_injection: skip_injection) }
    organization
    hero_image { Decidim::Dev.test_file("city.jpeg", "image/jpeg") } # Keep after organization
    banner_image { Decidim::Dev.test_file("city2.jpeg", "image/jpeg") } # Keep after organization
    published_at { Time.current }
    meta_scope { generate_localized_word(:assembly_meta_scope, skip_injection: skip_injection) }
    developer_group { generate_localized_title(:assembly_developer_group, skip_injection: skip_injection) }
    local_area { generate_localized_title(:assembly_local_area, skip_injection: skip_injection) }
    target { generate_localized_title(:assembly_target, skip_injection: skip_injection) }
    participatory_scope { generate_localized_title(:assembly_participatory_scope, skip_injection: skip_injection) }
    participatory_structure { generate_localized_title(:assembly_participatory_structure, skip_injection: skip_injection) }
    show_statistics { true }
    private_space { false }
    purpose_of_action { generate_localized_description(:assembly_purpose_of_action, skip_injection: skip_injection) }
    composition { generate_localized_description(:assembly_composition, skip_injection: skip_injection) }
    creation_date { 1.month.ago }
    created_by { "others" }
    created_by_other { generate_localized_word(:assembly_created_by_other, skip_injection: skip_injection) }
    duration { 2.months.from_now.at_midnight }
    included_at { 1.month.ago }
    closing_date { 2.months.from_now.at_midnight }
    closing_date_reason { generate_localized_description(:assembly_closing_date_reason, skip_injection: skip_injection) }
    internal_organisation { generate_localized_description(:assembly_internal_organisation, skip_injection: skip_injection) }
    is_transparent { true }
    special_features { generate_localized_description(:assembly_special_features, skip_injection: skip_injection) }
    twitter_handler { "others" }
    facebook_handler { "others" }
    instagram_handler { "others" }
    youtube_handler { "others" }
    github_handler { "others" }
    weight { 1 }
    announcement { generate_localized_title(:assembly_announcement, skip_injection: skip_injection) }

    trait :with_type do
      assembly_type { create :assemblies_type, organization: organization, skip_injection: skip_injection }
    end

    trait :promoted do
      promoted { true }
    end

    trait :unpublished do
      published_at { nil }
    end

    trait :published do
      published_at { Time.current }
    end

    trait :with_parent do
      parent { create :assembly, organization: organization, skip_injection: skip_injection }
    end

    trait :public do
      private_space { false }
    end

    trait :private do
      private_space { true }
    end

    trait :transparent do
      is_transparent { true }
    end

    trait :opaque do
      is_transparent { false }
    end
  end

  factory :assembly_user_role, class: "Decidim::AssemblyUserRole" do
    transient do
      skip_injection { false }
    end
    user
    assembly { create :assembly, organization: user.organization, skip_injection: skip_injection }
    role { "admin" }
  end

  factory :assembly_admin, parent: :user, class: "Decidim::User" do
    transient do
      skip_injection { false }
      assembly { create(:assembly, skip_injection: skip_injection) }
    end

    organization { assembly.organization }
    admin_terms_accepted_at { Time.current }

    after(:create) do |user, evaluator|
      create :assembly_user_role,
             user: user,
             assembly: evaluator.assembly,
             skip_injection: evaluator.skip_injection,
             role: :admin
    end
  end

  factory :assembly_moderator, parent: :user, class: "Decidim::User" do
    transient do
      skip_injection { false }
      assembly { create(:assembly, skip_injection: skip_injection) }
    end

    organization { assembly.organization }
    admin_terms_accepted_at { Time.current }

    after(:create) do |user, evaluator|
      create :assembly_user_role,
             user: user,
             assembly: evaluator.assembly,
             skip_injection: evaluator.skip_injection,
             role: :moderator
    end
  end

  factory :assembly_collaborator, parent: :user, class: "Decidim::User" do
    transient do
      skip_injection { false }
      assembly { create(:assembly, skip_injection: skip_injection) }
    end

    organization { assembly.organization }
    admin_terms_accepted_at { Time.current }

    after(:create) do |user, evaluator|
      create :assembly_user_role,
             user: user,
             assembly: evaluator.assembly,
             skip_injection: evaluator.skip_injection,
             role: :collaborator
    end
  end

  factory :assembly_valuator, parent: :user, class: "Decidim::User" do
    transient do
      skip_injection { false }
      assembly { create(:assembly, skip_injection: skip_injection) }
    end

    organization { assembly.organization }
    admin_terms_accepted_at { Time.current }

    after(:create) do |user, evaluator|
      create :assembly_user_role,
             user: user,
             assembly: evaluator.assembly,
             skip_injection: evaluator.skip_injection,
             role: :valuator
    end
  end

  factory :assembly_member, class: "Decidim::AssemblyMember" do
    transient do
      skip_injection { false }
    end
    assembly { create(:assembly, skip_injection: skip_injection) }
    full_name { Faker::Name.name }
    gender { Faker::Lorem.word }
    birthday { Faker::Date.birthday(min_age: 18, max_age: 65) }
    birthplace { Faker::Lorem.word }
    position { Decidim::AssemblyMember::POSITIONS.first }
    designation_date { Faker::Date.between(from: 1.year.ago, to: 1.month.ago) }

    trait :ceased do
      ceased_date { Faker::Date.between(from: 1.day.ago, to: 5.days.ago) }
    end

    trait :with_user do
      user { create(:user, organization: assembly.organization, skip_injection: skip_injection) }
    end
  end
end
