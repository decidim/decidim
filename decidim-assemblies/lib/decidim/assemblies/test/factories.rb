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
    title { generate_localized_title }
    organization
  end

  factory :assembly, class: "Decidim::Assembly" do
    title { generate_localized_title }
    slug { generate(:assembly_slug) }
    subtitle { generate_localized_title }
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
    show_statistics { true }
    private_space { false }
    purpose_of_action { Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title } }
    composition { Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title } }
    creation_date { 1.month.ago }
    created_by { "others" }
    created_by_other { Decidim::Faker::Localized.word }
    duration { 2.months.from_now.at_midnight }
    included_at { 1.month.ago }
    closing_date { 2.months.from_now.at_midnight }
    closing_date_reason { Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title } }
    internal_organisation { Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title } }
    is_transparent { true }
    special_features { Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title } }
    twitter_handler { "others" }
    facebook_handler { "others" }
    instagram_handler { "others" }
    youtube_handler { "others" }
    github_handler { "others" }
    weight { 1 }
    announcement { generate_localized_title }

    trait :with_type do
      assembly_type { create :assemblies_type, organization: }
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
      parent { create :assembly, organization: }
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
    user
    assembly { create :assembly, organization: user.organization }
    role { "admin" }
  end

  factory :assembly_admin, parent: :user, class: "Decidim::User" do
    transient do
      assembly { create(:assembly) }
    end

    organization { assembly.organization }

    after(:create) do |user, evaluator|
      create :assembly_user_role,
             user:,
             assembly: evaluator.assembly,
             role: :admin
    end
  end

  factory :assembly_moderator, parent: :user, class: "Decidim::User" do
    transient do
      assembly { create(:assembly) }
    end

    organization { assembly.organization }

    after(:create) do |user, evaluator|
      create :assembly_user_role,
             user:,
             assembly: evaluator.assembly,
             role: :moderator
    end
  end

  factory :assembly_collaborator, parent: :user, class: "Decidim::User" do
    transient do
      assembly { create(:assembly) }
    end

    organization { assembly.organization }

    after(:create) do |user, evaluator|
      create :assembly_user_role,
             user:,
             assembly: evaluator.assembly,
             role: :collaborator
    end
  end

  factory :assembly_valuator, parent: :user, class: "Decidim::User" do
    transient do
      assembly { create(:assembly) }
    end

    organization { assembly.organization }

    after(:create) do |user, evaluator|
      create :assembly_user_role,
             user:,
             assembly: evaluator.assembly,
             role: :valuator
    end
  end

  factory :assembly_member, class: "Decidim::AssemblyMember" do
    assembly { create(:assembly) }

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
      user { create(:user, organization: assembly.organization) }
    end
  end
end
