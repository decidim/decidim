# frozen_string_literal: true

require "decidim/faker/localized"
require "decidim/dev"

FactoryBot.define do
  sequence(:assembly_slug) do |n|
    "#{Faker::Internet.slug(nil, "-")}-#{n}"
  end

  factory :assembly, class: "Decidim::Assembly" do
    title { Decidim::Faker::Localized.sentence(3) }
    slug { generate(:assembly_slug) }
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
    show_statistics { true }
    private_space { false }
    purpose_of_action { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(2) } }
    composition { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(2) } }
    assembly_type { "others" }
    assembly_type_other { Decidim::Faker::Localized.sentence(1) }
    creation_date { 1.month.ago }
    created_by { "others" }
    created_by_other { Decidim::Faker::Localized.word }
    duration { 2.months.from_now.at_midnight }
    included_at { 1.month.ago }
    closing_date { 2.months.from_now.at_midnight }
    closing_date_reason { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(2) } }
    internal_organisation { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(2) } }
    is_transparent { true }
    special_features { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(2) } }
    twitter_handler { "others" }
    facebook_handler { "others" }
    instagram_handler { "others" }
    youtube_handler { "others" }
    github_handler { "others" }

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
      parent { create :assembly, organization: organization }
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
             user: user,
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
             user: user,
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
             user: user,
             assembly: evaluator.assembly,
             role: :collaborator
    end
  end

  factory :assembly_member, class: "Decidim::AssemblyMember" do
    assembly { create(:assembly) }

    full_name { Faker::Name.name }
    gender { Faker::Lorem.word }
    birthday { Faker::Date.birthday(18, 65) }
    birthplace { Faker::Lorem.word }
    position { Decidim::AssemblyMember::POSITIONS.first }
    designation_date { Faker::Date.between(1.year.ago, 1.month.ago) }
    designation_mode { Faker::Lorem.word }

    trait :ceased do
      ceased_date { Faker::Date.between(1.day.ago, 5.days.ago) }
    end

    trait :with_user do
      user { create(:user, organization: assembly.organization) }
    end
  end
end
