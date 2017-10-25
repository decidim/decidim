# frozen_string_literal: true

require "decidim/core/test/factories"
require "decidim/participatory_processes/test/factories"

FactoryGirl.define do
  factory :meeting_feature, parent: :feature do
    name { Decidim::Features::Namer.new(participatory_space.organization.available_locales, :meetings).i18n_name }
    manifest_name :meetings
    participatory_space { create(:participatory_process, :with_steps, organization: organization) }
  end

  factory :meeting, class: Decidim::Meetings::Meeting do
    title { Decidim::Faker::Localized.sentence(3) }
    description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(4) } }
    location { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(4) } }
    location_hints { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(4) } }
    address { Faker::Lorem.sentence(3) }
    latitude { Faker::Address.latitude }
    longitude { Faker::Address.longitude }
    start_time { 1.day.from_now }
    end_time { start_time.advance(hours: 2) }
    feature { build(:feature, manifest_name: "meetings") }

    trait :closed do
      closing_report { Decidim::Faker::Localized.sentence(3) }
      attendees_count { rand(50) }
      contributions_count { rand(50) }
      attending_organizations { Array.new(3) { Faker::GameOfThrones.house }.join(", ") }
      closed_at { Time.current }
    end

    trait :with_registrations_enabled do
      registrations_enabled { true }
      available_slots { 10 }
      registration_terms { Decidim::Faker::Localized.sentence(3) }
    end
  end

  factory :registration, class: Decidim::Meetings::Registration do
    meeting
    user
  end
end
