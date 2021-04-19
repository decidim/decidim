# frozen_string_literal: true

require "decidim/faker/localized"
require "decidim/dev"

FactoryBot.define do
  sequence(:conference_slug) do |n|
    "#{Decidim::Faker::Internet.slug(words: nil, glue: "-")}-#{n}"
  end

  factory :conference, class: "Decidim::Conference" do
    title { generate_localized_title }
    slug { generate(:conference_slug) }
    slogan { generate_localized_title }
    short_description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title } }
    description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title } }
    objectives { Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title } }
    organization
    hero_image { Decidim::Dev.test_file("city.jpeg", "image/jpeg") } # Keep after organization
    banner_image { Decidim::Dev.test_file("city2.jpeg", "image/jpeg") } # Keep after organization
    published_at { Time.current }
    location { Faker::Lorem.sentence(word_count: 3) }
    show_statistics { true }
    start_date { 1.month.ago }
    end_date { 1.month.ago + 3.days }
    registration_terms { generate_localized_title }

    trait :promoted do
      promoted { true }
    end

    trait :unpublished do
      published_at { nil }
    end

    trait :published do
      published_at { Time.current }
    end

    trait :diploma do
      main_logo { Decidim::Dev.test_file("avatar.jpg", "image/jpeg") }
      signature { Decidim::Dev.test_file("avatar.jpg", "image/jpeg") }
      sign_date { 5.days.from_now }
      signature_name { "Signature name" }
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

  factory :conference_valuator, parent: :user, class: "Decidim::User" do
    transient do
      conference { create(:conference) }
    end

    organization { conference.organization }

    after(:create) do |user, evaluator|
      create :conference_user_role,
             user: user,
             conference: evaluator.conference,
             role: :valuator
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
    avatar { Decidim::Dev.test_file("avatar.jpg", "image/jpeg") }

    trait :with_user do
      user { create(:user, organization: conference.organization) }
    end
  end

  factory :registration_type, class: "Decidim::Conferences::RegistrationType" do
    conference

    title { generate_localized_title }
    description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title } }
    published_at { Time.current }
    price { Faker::Number.between(from: 1, to: 300) }
    weight { Faker::Number.between(from: 1, to: 10) }

    trait :unpublished do
      published_at { nil }
    end

    trait :published do
      published_at { Time.current }
    end
  end

  factory :conference_registration, class: "Decidim::Conferences::ConferenceRegistration" do
    conference
    user
    registration_type
    confirmed_at { Time.current }

    trait :confirmed do
      confirmed_at { Time.current }
    end

    trait :unconfirmed do
      confirmed_at { nil }
    end
  end

  factory :conference_invite, class: "Decidim::Conferences::ConferenceInvite" do
    conference
    user
    sent_at { Time.current - 1.day }
    accepted_at { nil }
    rejected_at { nil }
    registration_type

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
    weight { Faker::Number.between(from: 1, to: 10) }
    link { Faker::Internet.url }
    partner_type { "main_promotor" }
    logo { Decidim::Dev.test_file("avatar.jpg", "image/jpeg") }

    trait :main_promotor do
      partner_type { "main_promotor" }
    end

    trait :collaborator do
      partner_type { "collaborator" }
    end
  end

  factory :media_link, class: "Decidim::Conferences::MediaLink" do
    conference
    title { generate_localized_title }
    weight { Faker::Number.between(from: 1, to: 10) }
    link { Faker::Internet.url }
    date { 1.month.ago }
  end
end
