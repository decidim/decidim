# frozen_string_literal: true
require "decidim/faker/localized"
require "decidim/dev"

FactoryGirl.define do
  sequence :name do |n|
    "#{Faker::Name.name} #{n}"
  end

  sequence(:email) do |n|
    "user#{n}@example.org"
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
    name { Faker::Company.unique.name }
    reference_prefix { Faker::Name.suffix }
    twitter_handler { Faker::Hipster.word }
    facebook_handler { Faker::Hipster.word }
    instagram_handler { Faker::Hipster.word }
    youtube_handler { Faker::Hipster.word }
    github_handler { Faker::Hipster.word }
    sequence(:host) { |n| "#{n}.lvh.me" }
    description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(2) } }
    welcome_text { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(2) } }
    homepage_image { test_file("city.jpeg", "image/jpeg") }
    favicon { test_file("icon.png", "image/png") }
    default_locale { I18n.default_locale }
    available_locales { Decidim.available_locales }
    official_img_header { test_file("avatar.jpg", "image/jpeg") }
    official_img_footer { test_file("avatar.jpg", "image/jpeg") }
    official_url { Faker::Internet.url }
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
    meta_scope { Decidim::Faker::Localized.word }
    developer_group { Decidim::Faker::Localized.sentence(1) }
    local_area { Decidim::Faker::Localized.sentence(2) }
    target { Decidim::Faker::Localized.sentence(3) }
    participatory_scope { Decidim::Faker::Localized.sentence(1) }
    participatory_structure { Decidim::Faker::Localized.sentence(2) }
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

    trait :with_scope do
      after(:create) do |participatory_process, _evaluator|
        create(:scope,
               organization: participatory_process.organization)
      end
    end

    trait :with_steps do
      transient { current_step_ends 1.month.from_now }

      after(:create) do |participatory_process, evaluator|
        create(:participatory_process_step,
               active: true,
               end_date: evaluator.current_step_ends,
               participatory_process: participatory_process)
        participatory_process.reload
        participatory_process.steps.reload
      end
    end
  end

  factory :participatory_process_group, class: Decidim::ParticipatoryProcessGroup do
    name { Decidim::Faker::Localized.sentence(3) }
    description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(4) } }
    hero_image { test_file("city.jpeg", "image/jpeg") }
    organization
  end

  factory :participatory_process_step, class: Decidim::ParticipatoryProcessStep do
    title { Decidim::Faker::Localized.sentence(3) }
    description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(4) } }
    start_date 1.month.ago.at_midnight
    end_date 2.month.from_now.at_midnight
    position nil
    participatory_process

    after(:create) do |step, _evaluator|
      step.participatory_process.reload
      step.participatory_process.steps.reload
    end

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
    comments_notifications true
    replies_notifications true

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

    trait :collaborator do
      roles ["collaborator"]
    end
  end

  factory :user_group, class: Decidim::UserGroup do
    name { Faker::Educator.course }
    document_number { Faker::Number.number(8) + "X" }
    phone { Faker::PhoneNumber.phone_number }
    avatar { test_file("avatar.jpg", "image/jpeg") }

    transient do
      users []
    end

    trait :verified do
      verified_at { Time.current }
    end

    after(:create) do |user_group, evaluator|
      users = evaluator.users
      next if users.empty?

      users.each do |user|
        create(:user_group_membership, user: user, user_group: user_group)
      end
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
    organization { user.organization }
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
    published_at { Time.now }

    after(:create) do |feature, _evaluator|
      feature.participatory_process.steps.reload
    end

    trait :unpublished do
      published_at { nil }
    end

    trait :published do
      published_at { Time.current }
    end
  end

  factory :scope, class: Decidim::Scope do
    name { generate(:name) }
    organization
  end

  factory :dummy_resource, class: Decidim::DummyResource do
    title { generate(:name) }
    feature { create(:feature, manifest_name: "dummy") }
    author { create(:user, :confirmed, organization: feature.organization) }
  end

  factory :resource_link, class: Decidim::ResourceLink do
    name { generate(:slug) }
    to { build(:dummy_resource) }
    from { build(:dummy_resource, feature: to.feature) }
  end

  factory :newsletter, class: Decidim::Newsletter do
    author { build(:user, :confirmed, organization: organization) }
    organization

    subject { Decidim::Faker::Localized.sentence(3) }
    body { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(4) } }
  end

  factory :moderation, class: Decidim::Moderation do
    reportable { build(:dummy_resource) }
    participatory_process { reportable.feature.participatory_process }
  end

  factory :report, class: Decidim::Report do
    moderation
    user { build(:user, organization: moderation.reportable.organization) }
    reason "spam"
  end
end

def test_file(filename, content_type)
  asset = Decidim::Dev.asset(filename)
  Rack::Test::UploadedFile.new(asset, content_type)
end
