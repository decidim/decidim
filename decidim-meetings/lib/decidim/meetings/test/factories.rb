FactoryGirl.define do
  factory :meeting, class: Decidim::Meetings::Meeting do
    title { Decidim::Faker::Localized.sentence(3) }
    description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(4) } }
    short_description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(4) } }
    location { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(4) } }
    location_hints { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(4) } }
    address { Faker::Lorem.sentence(3) }
    latitude { Faker::Address.latitude }
    longitude { Faker::Address.longitude }
    start_time { 1.day.from_now }
    end_time { start_time.advance(hours: 2) }
    feature

    trait :closed do
      closing_report { Decidim::Faker::Localized.sentence(3) }
      attendees_count { rand(50) }
      contributions_count { rand(50) }
      attending_organizations { 3.times.map { Faker::GameOfThrones.house }.join(", ") }
    end
  end
end
