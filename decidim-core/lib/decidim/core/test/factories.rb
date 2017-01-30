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
    name { Decidim::Faker::Localized.sentence(3) }
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
    favicon { test_file("icon.png", "image/png") }
    default_locale I18n.default_locale
    available_locales Decidim.available_locales
  end

  factory :participatory_process, class: Decidim::ParticipatoryProcess do
    title { Decidim::Faker::Localized.sentence(3) }
    slug { generate(:slug) }
    subtitle { Decidim::Faker::Localized.sentence(1) }
    short_description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(2) } }
    description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(4) } }
    hero_image { test_file("city.jpeg", "image/jpeg") }
    banner_image { test_file("city2.jpeg", "image/jpeg") }
    published_at { Time.current }
    organization
    scope  { Decidim::Faker::Localized.word }
    domain { Decidim::Faker::Localized.word }
    developer_group { Faker::Company.name }
    end_date 2.month.from_now.at_midnight

    trait :promoted do
      promoted true
    end

    trait :unpublished do
      published_at nil
    end

    trait :published do
      published_at { Time.current }
    end

    trait :with_steps do
      after(:create) do |participatory_process, _evaluator|
        create(:participatory_process_step,
               active: true,
               participatory_process: participatory_process)
      end
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
    email                 { generate(:email) }
    password              "password1234"
    password_confirmation "password1234"
    name                  { generate(:name) }
    organization
    locale                { organization.default_locale }
    tos_agreement         "1"
    avatar                { test_file("avatar.jpg", "image/jpeg") }

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

  factory :user_group, class: Decidim::UserGroup do
    name { Faker::Educator.course }
    document_number { Faker::Number.number(8) + "X" }
    phone { Faker::PhoneNumber.phone_number }
    avatar { test_file("avatar.jpg", "image/jpeg") }

    trait :verified do
      verified { true }
    end
  end

  factory :user_group_membership, class: Decidim::UserGroupMembership do
    user
    user_group
  end

  factory :identity, class: Decidim::Identity do
    provider "facebook"
    sequence(:uid)
    user
  end

  factory :authorization, class: Decidim::Authorization do
    name "decidim/dummy_authorization_handler"
    user
    metadata { {} }
  end

  factory :static_page, class: Decidim::StaticPage do
    slug { generate(:slug) }
    title { Decidim::Faker::Localized.sentence(3) }
    content { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(4) } }
    organization

    trait :default do
      slug { Decidim::StaticPage::DEFAULT_PAGES.sample }
    end
  end

  factory :attachment, class: Decidim::Attachment do
    title { Decidim::Faker::Localized.sentence(3) }
    description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(4) } }
    file { test_file("city.jpeg", "image/jpeg") }
    attached_to { build(:participatory_process) }

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
    name { Decidim::Faker::Localized.sentence(3) }
    participatory_process
    manifest_name "dummy"
  end

  factory :scope, class: Decidim::Scope do
    name { generate(:name) }
    organization
  end

  factory :dummy_resource, class: Decidim::DummyResource do
    title { generate(:name) }
    feature
  end

  factory :resource_link, class: Decidim::ResourceLink do
    name { generate(:slug) }
    to { build(:dummy_resource) }
    from { build(:dummy_resource, feature: to.feature) }
  end
end

def test_file(filename, content_type)
  asset = Decidim::Dev.asset(filename)
  Rack::Test::UploadedFile.new(asset, content_type)
end
