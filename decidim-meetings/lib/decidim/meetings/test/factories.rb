# frozen_string_literal: true
FactoryGirl.define do
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
  end
end
