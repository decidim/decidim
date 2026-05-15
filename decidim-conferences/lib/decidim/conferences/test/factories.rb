# frozen_string_literal: true

require "decidim/faker/localized"
require "decidim/dev"
require "decidim/meetings/test/factories"

FactoryBot.define do
  sequence(:conference_slug) do |n|
    "#{Decidim::Faker::Internet.slug(words: nil, glue: "-")}-#{n}"
  end

  factory :conference, class: "Decidim::Conference" do
    transient do
      skip_injection { false }
    end
    title { generate_localized_title(:conference_title, skip_injection:) }
    slug { generate(:conference_slug) }
    weight { 1 }
    slogan { generate_localized_title(:conference_slogan, skip_injection:) }
    short_description { generate_localized_description(:conference_short_description, skip_injection:) }
    description { generate_localized_description(:conference_description, skip_injection:) }
    objectives { generate_localized_description(:conference_objectives, skip_injection:) }
    organization
    hero_image { Decidim::Dev.test_file("city.jpeg", "image/jpeg") } # Keep after organization
    banner_image { Decidim::Dev.test_file("city2.jpeg", "image/jpeg") } # Keep after organization
    published_at { Time.current }
    deleted_at { nil }
    location { Faker::Lorem.sentence(word_count: 3) }
    show_statistics { true }
    start_date { 1.month.ago }
    end_date { 1.month.ago + 3.days }
    registration_terms { generate_localized_title(:conference_registration_terms, skip_injection:) }
    registrations_enabled { true }

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
    transient do
      skip_injection { false }
    end
    user
    conference { create(:conference, organization: user.organization, skip_injection:) }
    role { "admin" }
  end

  factory :conference_admin, parent: :user, class: "Decidim::User" do
    transient do
      skip_injection { false }
      conference { create(:conference, skip_injection:) }
    end

    organization { conference.organization }
    admin_terms_accepted_at { Time.current }

    after(:create) do |user, evaluator|
      create(:conference_user_role,
             user:,
             conference: evaluator.conference,
             role: :admin,
             skip_injection: evaluator.skip_injection)
    end
  end

  factory :conference_moderator, parent: :user, class: "Decidim::User" do
    transient do
      skip_injection { false }
      conference { create(:conference, skip_injection:) }
    end

    organization { conference.organization }
    admin_terms_accepted_at { Time.current }

    after(:create) do |user, evaluator|
      create(:conference_user_role,
             user:,
             conference: evaluator.conference,
             role: :moderator,
             skip_injection: evaluator.skip_injection)
    end
  end

  factory :conference_collaborator, parent: :user, class: "Decidim::User" do
    transient do
      skip_injection { false }
      conference { create(:conference, skip_injection:) }
    end

    organization { conference.organization }
    admin_terms_accepted_at { Time.current }

    after(:create) do |user, evaluator|
      create(:conference_user_role,
             user:,
             conference: evaluator.conference,
             role: :collaborator,
             skip_injection: evaluator.skip_injection)
    end
  end

  factory :conference_evaluator, parent: :user, class: "Decidim::User" do
    transient do
      skip_injection { false }
      conference { create(:conference, skip_injection:) }
    end

    organization { conference.organization }
    admin_terms_accepted_at { Time.current }

    after(:create) do |user, evaluator|
      create(:conference_user_role,
             user:,
             conference: evaluator.conference,
             role: :evaluator,
             skip_injection: evaluator.skip_injection)
    end
  end

  factory :conference_speaker, class: "Decidim::ConferenceSpeaker" do
    transient do
      skip_injection { false }
    end
    conference { create(:conference, skip_injection:) }

    full_name { Faker::Name.name }
    position { Decidim::Faker::Localized.word }
    affiliation { Decidim::Faker::Localized.word }
    short_bio { generate_localized_title(:conference_speaker_short_bio, skip_injection:) }
    twitter_handle { Faker::Internet.user_name }
    personal_url { Faker::Internet.url }

    trait :with_avatar do
      avatar { Decidim::Dev.test_file("avatar.jpg", "image/jpeg") }
    end

    trait :with_user do
      user { create(:user, organization: conference.organization, skip_injection:) }
    end

    trait :with_meeting do
      transient do
        meetings_component { create(:meetings_component, participatory_space: conference.participatory_space, skip_injection:) }
      end

      after :build do |conference_speaker, evaluator|
        conference_speaker.conference_speaker_conference_meetings << build(:conference_speaker_conference_meeting,
                                                                           meetings_component: evaluator.meetings_component,
                                                                           conference_speaker:,
                                                                           skip_injection: evaluator.skip_injection)
      end
    end

    trait :published do
      published_at { Time.current }
    end
  end

  factory :conference_speaker_conference_meeting, class: "Decidim::ConferenceSpeakerConferenceMeeting" do
    transient do
      skip_injection { false }
      conference { create(:conference, skip_injection:) }
      meetings_component { create(:meetings_component, skip_injection:, participatory_space: conference.participatory_space) }
    end

    conference_meeting { create(:conference_meeting, :published, conference:, skip_injection:, component: meetings_component) }
    conference_speaker { create(:conference_speaker, conference:, skip_injection:) }
  end

  factory :conference_meeting_registration_type, class: "Decidim::Conferences::ConferenceMeetingRegistrationType" do
    transient do
      skip_injection { false }
      conference { create(:conference, skip_injection:) }
    end

    conference_meeting
    registration_type { build(:registration_type, conference:, skip_injection:) }
  end

  factory :conference_meeting, parent: :meeting, class: "Decidim::ConferenceMeeting" do
    transient do
      skip_injection { false }
      conference { create(:conference) }
    end

    after :build do |conference_meeting, evaluator|
      conference_meeting.conference_meeting_registration_types << build(:conference_meeting_registration_type,
                                                                        conference_meeting:,
                                                                        conference: evaluator.conference,
                                                                        skip_injection: evaluator.skip_injection)
    end
  end

  factory :registration_type, class: "Decidim::Conferences::RegistrationType" do
    transient do
      skip_injection { false }
    end
    conference

    title { generate_localized_title(:registration_type_title, skip_injection:) }
    description { generate_localized_description(:registration_type_description, skip_injection:) }
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
    transient do
      skip_injection { false }
    end
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
    transient do
      skip_injection { false }
    end
    conference
    user
    sent_at { 1.day.ago }
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
    transient do
      skip_injection { false }
    end
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
    transient do
      skip_injection { false }
    end
    conference
    title { generate_localized_title(:media_link_title, skip_injection:) }
    weight { Faker::Number.between(from: 1, to: 10) }
    link { Faker::Internet.url }
    date { 1.month.ago }
  end
end
