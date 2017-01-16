require "decidim/core/test/factories"
require "decidim/admin/test/factories"
require "decidim/comments/test/factories"

FactoryGirl.define do
  factory :result, class: Decidim::Results::Result do
    title { Decidim::Faker::Localized.sentence(3) }
    description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(4) } }
    short_description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(4) } }
    feature
  end
end
