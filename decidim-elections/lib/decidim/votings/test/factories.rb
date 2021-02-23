# frozen_string_literal: true

require "decidim/core/test/factories"
require "decidim/forms/test/factories"

FactoryBot.define do
  sequence(:voting_slug) do |n|
    "#{Decidim::Faker::Internet.slug(words: nil, glue: "-")}-#{n}"
  end

  factory :voting, class: "Decidim::Votings::Voting" do
    organization
    slug { generate(:voting_slug) }
    title { generate_localized_title }
    description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title } }
    published_at { Time.current }
    start_time { 1.day.from_now }
    end_time { 3.days.from_now }
    decidim_scope_id { create(:scope, organization: organization).id }
    banner_image { Decidim::Dev.test_file("city2.jpeg", "image/jpeg") }
    introductory_image { Decidim::Dev.test_file("city.jpeg", "image/jpeg") }
    voting_type { "hybrid" }

    trait :unpublished do
      published_at { nil }
    end

    trait :published do
      published_at { Time.current }
    end

    trait :upcoming do
      start_time { 7.days.from_now }
      end_time { 1.month.from_now + 7.days }
    end

    trait :ongoing do
      start_time { 7.days.ago }
      end_time { 1.month.from_now - 7.days }
    end

    trait :finished do
      start_time { 1.month.ago - 7.days }
      end_time { 7.days.ago }
    end

    trait :promoted do
      promoted { true }
    end

    trait :online do
      voting_type { "online" }
    end

    trait :in_person do
      voting_type { "in_person" }
    end

    trait :hybrid do
      voting_type { "hybrid" }
    end
  end

  factory :polling_station, class: "Decidim::Votings::PollingStation" do
    title { generate_localized_title }
    location { Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title } }
    location_hints { Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title } }
    address { Faker::Lorem.sentence(word_count: 3) }
    latitude { Faker::Address.latitude }
    longitude { Faker::Address.longitude }
    voting { create(:voting) }
  end

  factory :polling_officer, class: "Decidim::Votings::PollingOfficer" do
    user { create :user, organization: voting.organization }
    voting { create :voting }
  end

  factory :monitoring_committee_member, class: "Decidim::Votings::MonitoringCommitteeMember" do
    user
    voting { create :voting, organization: user.organization }
  end
end
