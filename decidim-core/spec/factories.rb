require "decidim/faker/localized"

FactoryGirl.define do
  factory :organization, class: Decidim::Organization do
    name { Faker::Company.name }
    sequence(:host) { |n| "#{n}.lvh.me" }
    description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(2) } }
    default_locale I18n.default_locale
    available_locales Decidim.available_locales
  end

  factory :participatory_process, class: Decidim::ParticipatoryProcess do
    title { Decidim::Faker::Localized.sentence(3) }
    slug { Faker::Internet.slug(nil, '-') }
    subtitle { Decidim::Faker::Localized.sentence(1) }
    short_description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(2) } }
    description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(4) } }
    hero_image { test_file("city.jpeg", "image/jpeg") }
    banner_image { test_file("city2.jpeg", "image/jpeg") }
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

  factory :participatory_process_attachment, class: Decidim::ParticipatoryProcessAttachment do
    title { Decidim::Faker::Localized.sentence(3) }
    description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(4) } }
    file { test_file("city.jpeg", "image/jpeg") }
    participatory_process

    trait :with_image do
      file { test_file("city.jpeg", "image/jpeg") }
    end

    trait :with_pdf do
      file { test_file("Exampledocument.pdf", "application/pdf") }
    end

    trait :with_doc do
      file { test_file("Exampledocument.doc", "application/msword") }
    end

    trait :with_odt do
      file { test_file("Exampledocument.odt", "application/vnd.oasis.opendocument") }
    end
  end

  factory :component, class: Decidim::Component do
    name { Decidim::Faker::Localized.sentence(3) }
    participatory_process
    component_type "dummy"
  end
end


def test_file(filename, content_type)
  Rack::Test::UploadedFile.new(File.join(File.dirname(__FILE__), "..", "..", "decidim-dev", "spec", "support", filename), content_type)
end
