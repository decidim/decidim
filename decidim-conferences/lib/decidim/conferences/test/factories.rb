# frozen_string_literal: true

require "decidim/faker/localized"
require "decidim/dev"

FactoryBot.define do
  sequence(:conference_slug) do |n|
    "#{Faker::Internet.slug(nil, "-")}-#{n}"
  end

  factory :conference, class: "Decidim::Conference" do
    title { generate_localized_title }
    slug { generate(:conference_slug) }
    slogan { generate_localized_title }
    short_description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title } }
    description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title } }
    objectives { Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title } }
    hero_image { Decidim::Dev.test_file("city.jpeg", "image/jpeg") }
    banner_image { Decidim::Dev.test_file("city2.jpeg", "image/jpeg") }
    published_at { Time.current }
    location { Faker::Lorem.sentence(3) }
    organization
    show_statistics { true }
    start_date { 1.month.ago }
    end_date { 1.month.ago + 3.days }

    trait :promoted do
      promoted { true }
    end

    trait :unpublished do
      published_at { nil }
    end

    trait :published do
      published_at { Time.current }
    end
  end

  factory :conference_user_role, class: "Decidim::ConferenceUserRole" do
    user
    conference { create :conference, organization: user.organization }
    role { "admin" }
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

  factory :conference_speaker, class: "Decidim::ConferenceSpeaker" do
    conference { create(:conference) }

    full_name { Faker::Name.name }
    position { Decidim::Faker::Localized.word }
    affiliation { Decidim::Faker::Localized.word }
    short_bio { generate_localized_title }
    twitter_handle { Faker::Internet.user_name }
    personal_url { Faker::Internet.url }

    trait :with_user do
      user { create(:user, organization: conference.organization) }
    end
  end

  factory :conference_registration, class: "Decidim::Conferences::ConferenceRegistration" do
    conference
    user
  end

  factory :conference_invite, class: "Decidim::Conferences::ConferenceInvite" do
    conference
    user
    sent_at { Time.current - 1.day }
    accepted_at { nil }
    rejected_at { nil }

    trait :accepted do
      accepted_at { Time.current }
    end

    trait :rejected do
      rejected_at { Time.current }
    end
  end

  factory :partner, class: "Decidim::Conferences::Partner" do
    conference

    name { Faker::Name.name }
    weight { Faker::Number.between(1, 10) }
    link { Faker::Internet.url }
    partner_type { nil }
    logo { Decidim::Dev.test_file("avatar.jpg", "image/jpeg") }

    trait :main_promotor do
      partner_type { "main_promotor" }
    end

    trait :collaborator do
      partner_type { "collaborator" }
    end
  end
end
