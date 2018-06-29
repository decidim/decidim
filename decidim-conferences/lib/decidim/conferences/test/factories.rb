# frozen_string_literal: true

require "decidim/faker/localized"
require "decidim/dev"

FactoryBot.define do
  sequence(:conference_slug) do |n|
    "#{Faker::Internet.slug(nil, "-")}-#{n}"
  end

  factory :conference, class: "Decidim::Conference" do
    title { Decidim::Faker::Localized.sentence(3) }
    slug { generate(:conference_slug) }
    slogan { Decidim::Faker::Localized.sentence(1) }
    short_description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(2) } }
    description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(4) } }
    objectives { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(4) } }
    hero_image { Decidim::Dev.test_file("city.jpeg", "image/jpeg") }
    banner_image { Decidim::Dev.test_file("city2.jpeg", "image/jpeg") }
    published_at { Time.current }
    organization
    show_statistics true
    start_date { 1.month.ago }
    end_date { 1.month.ago + 3.days }

    trait :promoted do
      promoted true
    end

    trait :unpublished do
      published_at nil
    end

    trait :published do
      published_at { Time.current }
    end
  end

  factory :conference_user_role, class: "Decidim::ConferenceUserRole" do
    user
    conference { create :conference, organization: user.organization }
    role "admin"
  end

  factory :conference_admin, parent: :user, class: "Decidim::User" do
    transient do
      conference { create(:conference) }
    end

    organization { conference.organization }

    after(:create) do |user, evaluator|
      create :conference_user_role,
             user: user,
             conference: evaluator.conference,
             role: :admin
    end
  end

  factory :conference_moderator, parent: :user, class: "Decidim::User" do
    transient do
      conference { create(:conference) }
    end

    organization { conference.organization }

    after(:create) do |user, evaluator|
      create :conference_user_role,
             user: user,
             conference: evaluator.conference,
             role: :moderator
    end
  end

  factory :conference_collaborator, parent: :user, class: "Decidim::User" do
    transient do
      conference { create(:conference) }
    end

    organization { conference.organization }

    after(:create) do |user, evaluator|
      create :conference_user_role,
             user: user,
             conference: evaluator.conference,
             role: :collaborator
    end
  end
end
