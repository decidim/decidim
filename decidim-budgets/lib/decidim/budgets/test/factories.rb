# frozen_string_literal: true
require "decidim/faker/localized"
require "decidim/dev"

FactoryGirl.define do
  factory :project, class: Decidim::Budgets::Project do
    title { Decidim::Faker::Localized.sentence(3) }
    description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(4) } }
    short_description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(4) } }
    budget { Faker::Number.number(8) }
    feature
  end
end
