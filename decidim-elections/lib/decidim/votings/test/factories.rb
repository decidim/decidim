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
    census_contact_information { nil }

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

  factory :dataset, class: "Decidim::Votings::Census::Dataset" do
    voting { create(:voting) }
    file { "file.csv" }
    status { "init_data" }
    csv_row_raw_count { 1 }
    csv_row_processed_count { 1 }

    trait :with_data do
      after(:create) do |dataset|
        create_list(:datum, 5, dataset: dataset)
      end
    end

    trait :with_access_code_data do
      after(:create) do |dataset|
        create_list(:datum, 5, :with_access_code, dataset: dataset)
      end
    end

    trait :data_created do
      status { "data_created" }
    end

    trait :codes_generated do
      with_access_code_data
      status { "codes_generated" }
    end

    trait :frozen do
      status { "freeze" }
    end
  end

  factory :datum, class: "Decidim::Votings::Census::Datum" do
    dataset

    transient do
      document_number { Faker::IDNumber.spanish_citizen_number }
      document_type { %w(DNI NIE PASSPORT).sample }
      birthdate { Faker::Date.birthday(min_age: 18, max_age: 65) }
    end

    hashed_in_person_data { Digest::SHA256.hexdigest([document_number, document_type, birthdate].join(".")) }
    hashed_check_data { Digest::SHA256.hexdigest([document_number, document_type, birthdate, postal_code].join(".")) }

    full_name { Faker::Name.name }
    full_address { Faker::Address.full_address }
    postal_code { Faker::Address.postcode }
    mobile_phone_number { Faker::PhoneNumber.cell_phone }
    email { Faker::Internet.email }

    trait :with_access_code do
      access_code { SecureRandom.alphanumeric(8) }
      hashed_online_data { Digest::SHA256.hexdigest([hashed_check_data, access_code].join(".")) }
    end
  end

  factory :ballot_style, class: "Decidim::Votings::BallotStyle" do
    code { Faker::Lorem.word }
    voting { create(:voting) }

    trait :with_questions do
      transient do
        election { create(:election, :complete, component: create(:elections_component, participatory_space: voting)) }
      end
    end

    trait :with_ballot_style_questions do
      with_questions

      after(:create) do |ballot_style, evaluator|
        evaluator.election.questions.first(2).map { |question| create(:ballot_style_question, question: question, ballot_style: ballot_style) }
      end
    end
  end

  factory :ballot_style_question, class: "Decidim::Votings::BallotStyleQuestion" do
    question
    ballot_style
  end
end
