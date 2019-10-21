# frozen_string_literal: true

require "decidim/faker/localized"
require "decidim/dev"

require "decidim/participatory_processes/test/factories"
require "decidim/assemblies/test/factories"
require "decidim/comments/test/factories"

def generate_localized_title
  Decidim::Faker::Localized.localized { generate(:title) }
end

FactoryBot.define do
  sequence(:title) do |n|
    "#{Faker::Lorem.sentence(3)} #{n}"
  end

  sequence(:name) do |n|
    "#{Faker::Name.name} #{n}".delete("'")
  end

  sequence(:nickname) do |n|
    "#{Faker::Lorem.characters(rand(1..10))}_#{n}"
  end

  sequence(:hashtag_name) do |n|
    "#{Faker::Lorem.characters(rand(1..10))}_#{n}"
  end

  sequence(:email) do |n|
    "user#{n}@example.org"
  end

  sequence(:user_group_email) do |n|
    "usergroup#{n}@example.org"
  end

  sequence(:slug) do |n|
    "#{Faker::Internet.slug(nil, "-")}-#{n}"
  end

  sequence(:scope_name) do |n|
    "#{Faker::Lorem.sentence(1, true, 3)} #{n}".gsub("s", "z").gsub("S", "Z")
  end

  sequence(:scope_code) do |n|
    "#{Faker::Lorem.characters(4).upcase}-#{n}"
  end

  sequence(:area_name) do |n|
    "#{Faker::Lorem.sentence(1, true, 3)} #{n}"
  end

  factory :category, class: "Decidim::Category" do
    name { generate_localized_title }
    description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title } }

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
    description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title } }
    favicon { Decidim::Dev.test_file("icon.png", "image/png") }
    default_locale { Decidim.default_locale }
    available_locales { Decidim.available_locales }
    users_registration_mode { :enabled }
    official_img_header { Decidim::Dev.test_file("avatar.jpg", "image/jpeg") }
    official_img_footer { Decidim::Dev.test_file("avatar.jpg", "image/jpeg") }
    official_url { Faker::Internet.url }
    highlighted_content_banner_enabled { false }
    enable_omnipresent_banner { false }
    badges_enabled { true }
    user_groups_enabled { true }
    send_welcome_notification { true }
    force_users_to_authenticate_before_access_organization { false }
    smtp_settings do
      {
        "from" => "test@example.org",
        "user_name" => "test",
        "encrypted_password" => Decidim::AttributeEncryptor.encrypt("demo"),
        "port" => "25",
        "address" => "smtp.example.org"
      }
    end

    after(:create) do |organization|
      tos_page = Decidim::StaticPage.find_by(slug: "terms-and-conditions", organization: organization)
      create(:static_page, :tos, organization: organization) if tos_page.nil?
    end
  end

  factory :user, class: "Decidim::User" do
    email { generate(:email) }
    password { "password1234" }
    password_confirmation { password }
    name { generate(:name) }
    nickname { generate(:nickname) }
    organization
    locale { organization.default_locale }
    tos_agreement { "1" }
    avatar { Decidim::Dev.test_file("avatar.jpg", "image/jpeg") }
    personal_url { Faker::Internet.url }
    about { "<script>alert(\"ABOUT\");</script>" + Faker::Lorem.paragraph(2) }
    confirmation_sent_at { Time.current }
    accepted_tos_version { organization.tos_version }
    email_on_notification { true }

    trait :confirmed do
      confirmed_at { Time.current }
    end

    trait :deleted do
      email { "" }
      deleted_at { Time.current }
    end

    trait :admin do
      admin { true }
    end

    trait :user_manager do
      roles { ["user_manager"] }
    end

    trait :managed do
      email { "" }
      password { "" }
      password_confirmation { "" }
      encrypted_password { "" }
      managed { true }
    end

    trait :officialized do
      officialized_at { Time.current }
      officialized_as { generate_localized_title }
    end
  end

  factory :participatory_space_private_user, class: "Decidim::ParticipatorySpacePrivateUser" do
    user
    privatable_to { create :participatory_process, organization: user.organization }
  end

  factory :assembly_private_user, class: "Decidim::ParticipatorySpacePrivateUser" do
    user
    privatable_to { create :assembly, organization: user.organization }
  end

  factory :user_group, class: "Decidim::UserGroup" do
    transient do
      document_number { Faker::Number.number(8) + "X" }
      phone { Faker::PhoneNumber.phone_number }
      rejected_at { nil }
      verified_at { nil }
    end

    sequence(:name) { |n| "#{Faker::Company.name} #{n}" }
    email { generate(:user_group_email) }
    nickname { generate(:nickname) }
    avatar { Decidim::Dev.test_file("avatar.jpg", "image/jpeg") }
    about { "<script>alert(\"ABOUT\");</script>" + Faker::Lorem.paragraph(2) }
    organization

    transient do
      users { [] }
    end

    trait :verified do
      verified_at { Time.current }
    end

    trait :rejected do
      rejected_at { Time.current }
    end

    trait :confirmed do
      confirmed_at { Time.current }
    end

    after(:build) do |user_group, evaluator|
      user_group.extended_data = {
        document_number: evaluator.document_number,
        phone: evaluator.phone,
        rejected_at: evaluator.rejected_at,
        verified_at: evaluator.verified_at
      }
    end

    after(:create) do |user_group, evaluator|
      users = evaluator.users.dup
      next if users.empty?

      creator = users.shift
      create(:user_group_membership, user: creator, user_group: user_group, role: :creator)

      users.each do |user|
        create(:user_group_membership, user: user, user_group: user_group, role: :admin)
      end
    end
  end

  factory :user_group_membership, class: "Decidim::UserGroupMembership" do
    user
    role { :creator }
    user_group
  end

  factory :identity, class: "Decidim::Identity" do
    provider { "facebook" }
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
      granted_at { nil }
    end
  end

  factory :static_page, class: "Decidim::StaticPage" do
    slug { generate(:slug) }
    title { generate_localized_title }
    content { Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title } }
    organization { build(:organization) }

    trait :default do
      slug { (Decidim::StaticPage::DEFAULT_PAGES - ["terms-and-conditions"]).sample }
    end

    trait :tos do
      slug { "terms-and-conditions" }
      after(:create) do |tos_page|
        tos_page.organization.tos_version = tos_page.updated_at
        tos_page.organization.save!
      end
    end

    trait :with_topic do
      after(:create) do |static_page|
        topic = create(:static_page_topic, organization: static_page.organization)
        static_page.topic = topic
        static_page.save
      end
    end
  end

  factory :static_page_topic, class: "Decidim::StaticPageTopic" do
    title { generate_localized_title }
    description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title } }
    organization
  end

  factory :attachment_collection, class: "Decidim::AttachmentCollection" do
    name { generate_localized_title }
    description { generate_localized_title }
    weight { Faker::Number.number(1) }

    association :collection_for, factory: :participatory_process
  end

  factory :attachment, class: "Decidim::Attachment" do
    title { generate_localized_title }
    description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title } }
    file { Decidim::Dev.test_file("city.jpeg", "image/jpeg") }
    weight { Faker::Number.number(1) }
    attached_to { build(:participatory_process) }
    content_type { "image/jpeg" }
    file_size { 108_908 }

    trait :with_image do
      file { Decidim::Dev.test_file("city.jpeg", "image/jpeg") }
    end

    trait :with_pdf do
      file { Decidim::Dev.test_file("Exampledocument.pdf", "application/pdf") }
      content_type { "application/pdf" }
      file_size { 17_525 }
    end
  end

  factory :component, class: "Decidim::Component" do
    transient do
      organization { create(:organization) }
    end

    name { generate_localized_title }
    participatory_space { create(:participatory_process, organization: organization) }
    manifest_name { "dummy" }
    published_at { Time.current }
    settings do
      {
        dummy_global_translatable_text: generate_localized_title
      }
    end

    default_step_settings do
      {
        dummy_step_translatable_text: generate_localized_title
      }
    end

    trait :unpublished do
      published_at { nil }
    end

    trait :published do
      published_at { Time.current }
    end

    trait :with_amendments_enabled do
      settings do
        {
          amendments_enabled: true
        }
      end
    end

    trait :with_permissions do
      settings { { Random.rand => Random.new.bytes(5) } }
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
    scope_type { create(:scope_type, organization: organization) }
    organization { parent ? parent.organization : build(:organization) }
  end

  factory :subscope, parent: :scope do
    parent { build(:scope) }

    before(:create) do |object|
      object.parent.save unless object.parent.persisted?
    end
  end

  factory :area_type, class: "Decidim::AreaType" do
    name { Decidim::Faker::Localized.word }
    plural { Decidim::Faker::Localized.literal(name.values.first.pluralize) }
    organization
  end

  factory :area, class: "Decidim::Area" do
    name { Decidim::Faker::Localized.literal(generate(:area_name)) }
    organization
  end

  factory :coauthorship, class: "Decidim::Coauthorship" do
    coauthorable { create(:dummy_resource) }
    transient do
      organization { coauthorable.component.participatory_space.organization }
    end
    author { create(:user, :confirmed, organization: organization) }
  end

  factory :dummy_resource, class: "Decidim::DummyResources::DummyResource" do
    title { generate(:name) }
    component { create(:component, manifest_name: "dummy") }
    author { create(:user, :confirmed, organization: component.organization) }
    scope { create(:scope, organization: component.organization) }

    trait :published do
      published_at { Time.current }
    end
  end

  factory :resource_link, class: "Decidim::ResourceLink" do
    name { generate(:slug) }
    to { build(:dummy_resource) }
    from { build(:dummy_resource, component: to.component) }
  end

  factory :newsletter, class: "Decidim::Newsletter" do
    author { build(:user, :confirmed, organization: organization) }
    organization

    subject { generate_localized_title }

    body { Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title } }

    trait :sent do
      sent_at { Time.current }
    end
  end

  factory :moderation, class: "Decidim::Moderation" do
    reportable { build(:dummy_resource) }
    participatory_space { reportable.component.participatory_space }

    trait :hidden do
      hidden_at { 1.day.ago }
    end
  end

  factory :report, class: "Decidim::Report" do
    moderation
    user { build(:user, organization: moderation.reportable.organization) }
    reason { "spam" }
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

  factory :action_log, class: "Decidim::ActionLog" do
    transient do
      extra_data { {} }
    end

    organization { user.organization }
    user
    participatory_space { build :participatory_process, organization: organization }
    component { build :component, participatory_space: participatory_space }
    resource { build(:dummy_resource, component: component) }
    action { "create" }
    visibility { "admin-only" }
    extra do
      {
        component: {
          manifest_name: component.try(:manifest_name),
          title: component.try(:name) || component.try(:title)
        }.compact,
        participatory_space: {
          manifest_name: participatory_space.try(:class).try(:participatory_space_manifest).try(:name),
          title: participatory_space.try(:name) || participatory_space.try(:title)
        }.compact,
        resource: {
          title: resource.try(:name) || resource.try(:title)
        }.compact,
        user: {
          ip: user.try(:current_sign_in_ip),
          name: user.try(:name),
          nickname: user.try(:nickname)
        }.compact
      }.deep_merge(extra_data)
    end
  end

  factory :oauth_application, class: "Decidim::OAuthApplication" do
    organization
    sequence(:name) { |n| "OAuth application #{n}" }
    sequence(:organization_name) { |n| "OAuth application owner #{n}" }
    organization_url { "http://example.org" }
    organization_logo { Decidim::Dev.test_file("avatar.jpg", "image/jpeg") }
    redirect_uri { "https://app.example.org/oauth" }
    scopes { "public" }
  end

  factory :oauth_access_token, class: "Doorkeeper::AccessToken" do
    resource_owner_id { create(:user, organization: application.organization).id }
    application { build(:oauth_application) }
    token { SecureRandom.hex(32) }
    expires_in { 1.month.from_now }
    created_at { Time.current }
    scopes { "public" }
  end

  factory :searchable_resource, class: "Decidim::SearchableResource" do
    resource { build(:dummy_resource) }
    resource_id { resource.id }
    resource_type { resource.class.name }
    organization { resource.component.organization }
    decidim_participatory_space { resource.component.participatory_space }
    locale { I18n.locale }
    scope { resource.scope }
    content_a { Faker::Lorem.sentence }
    datetime { Time.current }
  end

  factory :content_block, class: "Decidim::ContentBlock" do
    organization
    scope { :homepage }
    manifest_name { :hero }
    weight { 1 }
    published_at { Time.current }
  end

  factory :hashtag, class: "Decidim::Hashtag" do
    name { generate(:hashtag_name) }
    organization
  end

  factory :metric, class: "Decidim::Metric" do
    organization
    day { Time.zone.today }
    metric_type { "random_metric" }
    cumulative { 2 }
    quantity { 1 }
    category { create :category }
    participatory_space { create :participatory_process, organization: organization }
    related_object { create :component, participatory_space: participatory_space }
  end

  factory :amendment, class: "Decidim::Amendment" do
    amendable { build(:dummy_resource) }
    emendation { build(:dummy_resource) }
    amender { emendation.try(:creator_author) || emendation.try(:author) }
    state { "evaluating" }

    trait :draft do
      state { "draft" }
    end

    trait :rejected do
      state { "rejected" }
    end
  end
end
