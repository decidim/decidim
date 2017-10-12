# frozen_string_literal: true

require "decidim/faker/localized"
require "decidim/dev"

require "decidim/participatory_processes/test/factories"
require "decidim/comments/test/factories"

FactoryBot.define do
  sequence(:name) do |n|
    "#{Faker::Name.name} #{n}"
  end

  sequence(:email) do |n|
    "user#{n}@example.org"
  end

  sequence(:slug) do |n|
    "#{Faker::Internet.slug(nil, "-")}-#{n}"
  end

  sequence(:scope_name) do |n|
    "#{Faker::Lorem.sentence(1, true, 3)} #{n}"
  end

  sequence(:scope_code) do |n|
    "#{Faker::Lorem.characters(4).upcase}-#{n}"
  end

  factory :category, class: "Decidim::Category" do
    name { Decidim::Faker::Localized.sentence(3) }
    description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(2) } }

    association :participatory_space, factory: :participatory_process
  end

  factory :subcategory, parent: :category do
    parent { build(:category) }

    participatory_space { parent.participatory_space }
  end

  factory :organization, class: "Decidim::Organization" do
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
    homepage_image { Decidim::Dev.test_file("city.jpeg", "image/jpeg") }
    favicon { Decidim::Dev.test_file("icon.png", "image/png") }
    default_locale { Decidim.default_locale }
    available_locales { Decidim.available_locales }
    official_img_header { Decidim::Dev.test_file("avatar.jpg", "image/jpeg") }
    official_img_footer { Decidim::Dev.test_file("avatar.jpg", "image/jpeg") }
    official_url { Faker::Internet.url }
  end

  factory :user, class: "Decidim::User" do
    email { generate(:email) }
    password "password1234"
    password_confirmation "password1234"
    name { generate(:name) }
    organization
    locale { organization.default_locale }
    tos_agreement "1"
    avatar { Decidim::Dev.test_file("avatar.jpg", "image/jpeg") }

    trait :confirmed do
      confirmed_at { Time.current }
    end

    trait :deleted do
      email ""
      deleted_at { Time.current }
    end

    trait :admin do
      admin { true }
    end

    trait :user_manager do
      roles { ["user_manager"] }
    end

    trait :process_admin do
      transient do
        participatory_process { create(:participatory_process) }
      end

      organization { participatory_process.organization }

      after(:create) do |user, evaluator|
        create :participatory_process_user_role,
               user: user,
               participatory_process: evaluator.participatory_process,
               role: :admin
      end
    end

    trait :process_collaborator do
      transient do
        participatory_process { create(:participatory_process) }
      end

      organization { participatory_process.organization }

      after(:create) do |user, evaluator|
        create :participatory_process_user_role,
               user: user,
               participatory_process: evaluator.participatory_process,
               role: :collaborator
      end
    end

    trait :process_moderator do
      transient do
        participatory_process { create(:participatory_process) }
      end

      organization { participatory_process.organization }

      after(:create) do |user, evaluator|
        create :participatory_process_user_role,
               user: user,
               participatory_process: evaluator.participatory_process,
               role: :moderator
      end
    end

    trait :managed do
      email { "" }
      password { "" }
      password_confirmation { "" }
      managed { true }
    end
  end

  factory :participatory_process_user_role, class: "Decidim::ParticipatoryProcessUserRole" do
    user
    participatory_process { create :participatory_process, organization: user.organization }
    role "admin"
  end

  factory :user_group, class: "Decidim::UserGroup" do
    name { Faker::Educator.course }
    document_number { Faker::Number.number(8) + "X" }
    phone { Faker::PhoneNumber.phone_number }
    avatar { Decidim::Dev.test_file("avatar.jpg", "image/jpeg") }
    organization

    transient do
      users []
    end

    trait :verified do
      verified_at { Time.current }
    end

    trait :rejected do
      rejected_at { Time.current }
    end

    after(:create) do |user_group, evaluator|
      users = evaluator.users
      next if users.empty?

      users.each do |user|
        create(:user_group_membership, user: user, user_group: user_group)
      end
    end
  end

  factory :user_group_membership, class: "Decidim::UserGroupMembership" do
    user
    user_group
  end

  factory :identity, class: "Decidim::Identity" do
    provider "facebook"
    sequence(:uid)
    user
    organization { user.organization }
  end

  factory :authorization, class: "Decidim::Authorization" do
    sequence(:name) { |n| "dummy_authorization_#{n}" }
    user
    metadata { {} }
    granted

    trait :granted do
      granted_at { 1.day.ago }
    end

    trait :pending do
      granted_at nil
    end
  end

  factory :static_page, class: "Decidim::StaticPage" do
    slug { generate(:slug) }
    title { Decidim::Faker::Localized.sentence(3) }
    content { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(4) } }
    organization

    trait :default do
      slug { Decidim::StaticPage::DEFAULT_PAGES.sample }
    end
  end

  factory :attachment, class: "Decidim::Attachment" do
    title { Decidim::Faker::Localized.sentence(3) }
    description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(4) } }
    file { Decidim::Dev.test_file("city.jpeg", "image/jpeg") }
    attached_to { build(:participatory_process) }

    trait :with_image do
      file { Decidim::Dev.test_file("city.jpeg", "image/jpeg") }
    end

    trait :with_pdf do
      file { Decidim::Dev.test_file("Exampledocument.pdf", "application/pdf") }
    end
  end

  factory :feature, class: "Decidim::Feature" do
    transient do
      organization { create(:organization) }
    end

    name { Decidim::Faker::Localized.sentence(3) }
    participatory_space { create(:participatory_process, organization: organization) }
    manifest_name "dummy"
    published_at { Time.current }

    trait :unpublished do
      published_at { nil }
    end

    trait :published do
      published_at { Time.current }
    end
  end

  factory :scope_type, class: "Decidim::ScopeType" do
    name { Decidim::Faker::Localized.word }
    plural { Decidim::Faker::Localized.literal(name.values.first.pluralize) }
    organization
  end

  factory :scope, class: "Decidim::Scope" do
    name { Decidim::Faker::Localized.literal(generate(:scope_name)) }
    code { generate(:scope_code) }
    scope_type
    organization { parent ? parent.organization : build(:organization) }
  end

  factory :subscope, parent: :scope do
    parent { build(:scope) }

    before(:create) do |object|
      object.parent.save unless object.parent.persisted?
    end
  end

  factory :dummy_resource, class: "Decidim::DummyResources::DummyResource" do
    title { generate(:name) }
    feature { create(:feature, manifest_name: "dummy") }
    author { create(:user, :confirmed, organization: feature.organization) }
  end

  factory :resource_link, class: "Decidim::ResourceLink" do
    name { generate(:slug) }
    to { build(:dummy_resource) }
    from { build(:dummy_resource, feature: to.feature) }
  end

  factory :newsletter, class: "Decidim::Newsletter" do
    author { build(:user, :confirmed, organization: organization) }
    organization

    subject { Decidim::Faker::Localized.sentence(3) }
    body { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(4) } }
  end

  factory :moderation, class: "Decidim::Moderation" do
    reportable { build(:dummy_resource) }
    participatory_space { reportable.feature.participatory_space }
  end

  factory :report, class: "Decidim::Report" do
    moderation
    user { build(:user, organization: moderation.reportable.organization) }
    reason "spam"
  end

  factory :impersonation_log, class: "Decidim::ImpersonationLog" do
    admin { build(:user, :admin) }
    user { build(:user, :managed, organization: admin.organization) }
    started_at { 10.minutes.ago }
  end

  factory :follow, class: "Decidim::Follow" do
    user do
      build(
        :user,
        organization: followable.try(:organization) || build(:organization)
      )
    end
    followable { build(:dummy_resource) }
  end

  factory :notification, class: "Decidim::Notification" do
    user do
      build(
        :user,
        organization: resource.try(:organization) || build(:organization)
      )
    end
    resource { build(:dummy_resource) }
    event_name { resource.class.name.underscore.tr("/", ".") }
    event_class { "Decidim::DummyResourceEvent" }
    extra do
      {
        some_extra_data: "1"
      }
    end
  end
end
