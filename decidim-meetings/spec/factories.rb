require_relative "../../decidim-core/spec/factories"
require_relative "../../decidim-admin/spec/factories"

FactoryGirl.define do
  factory :meeting, class: Decidim::Meetings::Meeting do
    title { Decidim::Faker::Localized.sentence(3) }
    description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(4) } }
    short_description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(4) } }
    location { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(4) } }
    location_hints { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(4) } }
    address { Faker::Lorem.sentence(3) }
    start_date { 1.day.from_now }
    end_date { 1.day.from_now + 2.hours }
    feature
  end
end
