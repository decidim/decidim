require_relative "../../decidim-core/spec/factories"
require_relative "../../decidim-comments/spec/factories"

FactoryGirl.define do
  factory :page, class: Decidim::Pages::Page do
    title { Decidim::Faker::Localized.sentence(3) }
    body { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(4) } }
    feature
  end
end
