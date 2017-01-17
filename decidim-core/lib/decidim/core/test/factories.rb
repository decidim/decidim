# frozen_string_literal: true
require "decidim/faker/localized"
require "decidim/dev"

FactoryGirl.define do
  sequence :name do |n|
    "#{Faker::Name.name} #{n}"
  end

  sequence(:email) do |n|
    "user#{n}@decidim.org"
  end

  sequence(:slug) do |n|
    "#{Faker::Internet.slug(nil, "-")}-#{n}"
  end

  factory :category, class: Decidim::Category do
    name { generate(:name) }
    description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(2) } }
    participatory_process
  end

  factory :subcategory, parent: :category do
    parent { build(:category) }

    before(:create) do |object|
      object.parent.save unless object.parent.persisted?
    end
  end

  factory :organization, class: Decidim::Organization do
    name { Faker::Company.name }
    twitter_handler { Faker::Hipster.word }
    sequence(:host) { |n| "#{n}.lvh.me" }
    description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(2) } }
    welcome_text { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(2) } }
    homepage_image { test_file("city.jpeg", "image/jpeg") }
    default_locale I18n.default_locale
    available_locales Decidim.available_locales
  end

  factory :participatory_process, class: Decidim::ParticipatoryProcess do
    title { generate(:name) }
    slug { generate(:slug) }
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

    trait :published do
      published_at { Time.current }
    end
  end

  factory :participatory_process_step, class: Decidim::ParticipatoryProcessStep do
    title { generate(:name) }
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
    email                 { generate(:email) }
    password              "password1234"
    password_confirmation "password1234"
    name                  { generate(:name) }
    organization
    locale                "en"
    tos_agreement         "1"
    avatar                { test_file("avatar.svg", "image/svg+xml") }

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
    slug { generate(:slug) }
    title { generate(:name) }
    content { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(4) } }
    organization

    trait :default do
      slug { Decidim::StaticPage::DEFAULT_PAGES.sample }
    end
  end

  factory :participatory_process_attachment, class: Decidim::ParticipatoryProcessAttachment do
    title { generate(:name) }
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

  factory :feature, class: Decidim::Feature do
    name { generate(:name) }
    participatory_process
    manifest_name "dummy"
  end

  factory :scope, class: Decidim::Scope do
    name { generate(:name) }
    organization
  end
end

def test_file(filename, content_type)
  asset = Decidim::Dev.asset(filename)
  Rack::Test::UploadedFile.new(asset, content_type)
end
