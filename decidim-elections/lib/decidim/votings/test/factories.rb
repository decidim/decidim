# frozen_string_literal: true

require "decidim/core/test/factories"
require "decidim/forms/test/factories"

def format_birthdate(birthdate)
  format("%04d%02d%02d", birthdate.year, birthdate.month, birthdate.day) # rubocop:disable Style/FormatStringToken
end

def hash_for(*data)
  Digest::SHA256.hexdigest(data.join("."))
end

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
    decidim_scope_id { create(:scope, organization:).id }
    banner_image { Decidim::Dev.test_file("city2.jpeg", "image/jpeg") }
    introductory_image { Decidim::Dev.test_file("city.jpeg", "image/jpeg") }
    voting_type { "hybrid" }
    census_contact_information { nil }
    show_check_census { true }

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

  factory :voting_election, parent: :election do
    transient do
      voting { create(:voting) }
      base_id { 20_000 }
    end

    component { create(:elections_component, organization:, participatory_space: voting) }
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

    trait :president do
      presided_polling_station { create :polling_station, voting: }
    end
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
        create_list(:datum, 5, dataset:)
      end
    end

    trait :with_access_code_data do
      after(:create) do |dataset|
        create_list(:datum, 5, :with_access_code, dataset:)
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

    hashed_in_person_data { hash_for(document_number, document_type, format_birthdate(birthdate)) }
    hashed_check_data { hash_for(document_number, document_type, format_birthdate(birthdate), postal_code) }

    full_name { Faker::Name.name }
    full_address { Faker::Address.full_address }
    postal_code { Faker::Address.postcode }
    mobile_phone_number { Faker::PhoneNumber.cell_phone }
    email { Faker::Internet.email }

    trait :with_access_code do
      access_code { Faker::Alphanumeric.alphanumeric(number: 8) }
      hashed_online_data { hash_for hashed_check_data, access_code }
    end
  end

  factory :ballot_style, class: "Decidim::Votings::BallotStyle" do
    code { Faker::Lorem.word.upcase }
    voting { create(:voting) }

    trait :with_questions do
      transient do
        election { create(:election, :complete, component: create(:elections_component, participatory_space: voting)) }
      end
    end

    trait :with_ballot_style_questions do
      with_questions

      after(:create) do |ballot_style, evaluator|
        evaluator.election.reload.questions.first(2).map { |question| create(:ballot_style_question, question:, ballot_style:) }
      end
    end
  end

  factory :ballot_style_question, class: "Decidim::Votings::BallotStyleQuestion" do
    question
    ballot_style
  end

  factory :in_person_vote, class: "Decidim::Votings::InPersonVote" do
    transient do
      voting { create(:voting) }
      component { create(:elections_component, participatory_space: voting) }
    end

    election { create(:election, component:) }
    sequence(:voter_id) { |n| "voter_#{n}" }
    status { "pending" }
    message_id { "decidim-test-authority.2.vote.in_person+v.5826de088371d1b15b38f00c8203871caec07041ed0c8fb0c6fb875f0df763b6" }
    polling_station { polling_officer.polling_station }
    polling_officer { create(:polling_officer, :president, voting:) }

    trait :accepted do
      status { "accepted" }
    end

    trait :rejected do
      status { "rejected" }
    end
  end

  factory :ps_closure, class: "Decidim::Votings::PollingStationClosure" do
    transient do
      number_of_votes { Faker::Number.number(digits: 2) }
    end

    election { create(:voting_election, :complete) }
    polling_station { polling_officer.polling_station }
    polling_officer { create(:polling_officer, :president, voting: election.participatory_space) }
    polling_officer_notes { Faker::Lorem.paragraph }
    monitoring_committee_notes { nil }
    signed_at { nil }
    phase { :count }
    validated_at { nil }

    trait :with_results do
      phase { :signature }

      after :create do |closure, evaluator|
        total_votes = evaluator.number_of_votes
        create_list(:in_person_vote, evaluator.number_of_votes, :accepted, voting: closure.election.participatory_space, election: closure.election)

        closure.election.questions.each do |question|
          max = total_votes
          question.answers.each do |answer|
            value = Faker::Number.between(from: 0, to: max)
            closure.results << create(:election_result, closurable: closure, election: closure.election, question:, answer:, value:)
            max -= value
          end
          value = Faker::Number.between(from: 0, to: max)
          closure.results << create(:election_result, :null_ballots, election: closure.election, question:, value:)
          max -= value
          closure.results << create(:election_result, :blank_ballots, election: closure.election, question:, value: max)
        end
        closure.results << create(:election_result, :total_ballots, closurable: closure, election: closure.election, value: total_votes)
      end
    end
  end
end
