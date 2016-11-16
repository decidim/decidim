require "decidim/faker/localized"

FactoryGirl.define do
  factory :organization, class: Decidim::Organization do
    name { Faker::Company.name }
    sequence(:host) { |n| "#{n}.lvh.me" }
    description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(2) } }
  end

  factory :participatory_process, class: Decidim::ParticipatoryProcess do
    title { Decidim::Faker::Localized.sentence(3) }
    slug { Faker::Internet.slug(nil, '-') }
    subtitle { Decidim::Faker::Localized.sentence(1) }
    short_description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(2) } }
    description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(4) } }
    hero_image { Rack::Test::UploadedFile.new(File.join(File.dirname(__FILE__), "..", "..", "decidim-dev", "spec", "support", "city.jpeg")) }
    banner_image { Rack::Test::UploadedFile.new(File.join(File.dirname(__FILE__), "..", "..", "decidim-dev", "spec", "support", "city2.jpeg")) }
    published_at { Time.current }
    organization

    trait :promoted do
      promoted true
    end

    trait :unpublished do
      published_at nil
    end
  end

  factory :participatory_process_step, class: Decidim::ParticipatoryProcessStep do
    title { Decidim::Faker::Localized.sentence(3) }
    short_description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(2) } }
    description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(4) } }
    start_date 1.month.ago.at_midnight
    end_date 2.month.from_now.at_midnight
    position nil
    participatory_process

    trait :active do
      active true
    end
  end

  factory :user, class: Decidim::User do
    sequence(:email)      { |n| "user#{n}@citizen.corp" }
    password              "password1234"
    password_confirmation "password1234"
    name                  { Faker::Name.name }
    organization
    locale                "en"
    tos_agreement         "1"

    trait :confirmed do
      confirmed_at { Time.current }
    end

    trait :admin do
      roles ["admin"]
    end

    trait :moderator do
      roles ["moderator"]
    end

    trait :official do
      roles ["official"]
    end
  end

  factory :authorization, class: Decidim::Authorization do
    name "decidim/dummy_authorization_handler"
    user
    metadata { {} }
  end

  factory :static_page, class: Decidim::StaticPage do
    slug { Faker::Internet.slug(nil, '-') }
    title { Decidim::Faker::Localized.sentence(3) }
    content { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(4) } }
    organization

    trait :default do
      slug { Decidim::StaticPage::DEFAULT_PAGES.sample }
    end
  end
end
