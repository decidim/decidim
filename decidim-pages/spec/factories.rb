require "decidim/core/test/factories"
require "decidim/comments/test/factories"

FactoryGirl.define do
  factory :page, class: Decidim::Pages::Page do
    title { Decidim::Faker::Localized.sentence(3) }
    body { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(4) } }
    feature { build(:feature, manifest_name: "pages") }
  end
end
