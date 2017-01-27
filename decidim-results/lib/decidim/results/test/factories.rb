# frozen_string_literal: true
require "decidim/faker/localized"
require "decidim/dev"

FactoryGirl.define do
  factory :result, class: Decidim::Results::Result do
    title { Decidim::Faker::Localized.sentence(3) }
    description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(4) } }
    short_description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(4) } }
    feature
  end
end
