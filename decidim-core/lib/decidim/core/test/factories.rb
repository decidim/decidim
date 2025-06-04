# frozen_string_literal: true

require "decidim/faker/localized"
require "decidim/faker/internet"
require "decidim/dev"
require "decidim/dev/test/factories"

require "decidim/participatory_processes/test/factories"
require "decidim/assemblies/test/factories"
require "decidim/comments/test/factories"

def generate_component_name(locales, manifest_name, skip_injection: false)
  prepend = skip_injection ? "" : "<script>alert(\"#{manifest_name}\");</script>"

  Decidim::Components::Namer.new(locales, manifest_name).i18n_name.transform_values { |v| [prepend, v].compact_blank.join(" ") }
end

def generate_localized_description(field = nil, skip_injection: false, before: "<p>", after: "</p>")
  Decidim::Faker::Localized.wrapped(before, after) do
    generate_localized_title(field, skip_injection:)
  end
end

def generate_localized_word(field = nil, skip_injection: false)
  skip_injection = true if field.nil?
  Decidim::Faker::Localized.localized do
    if skip_injection
      Faker::Lorem.word
    else
      "<script>alert(\"#{field}\");</script> #{Faker::Lorem.word}"
    end
  end
end

def generate_localized_title(field = nil, skip_injection: false)
  skip_injection = true if field.nil?

  Decidim::Faker::Localized.localized do
    if skip_injection
      generate(:title)
    else
      "<script>alert(\"#{field}\");</script> #{generate(:title)}"
    end
  end
end

def generate_title(field = nil, skip_injection:)
  skip_injection = true if field.nil?

  prepend = skip_injection ? "" : "<script>alert(\"#{field}\");</script>"

  "#{prepend}#{generate(:title)}"
end

FactoryBot.define do
  sequence(:title) do |n|
    "#{Faker::Lorem.sentence(word_count: 3)} #{n}".delete("'")
  end

  sequence(:name) do |_|
    Faker::Name.name.delete("'")
  end

  sequence(:nickname) do |n|
    "#{Faker::Lorem.characters(number: rand(1..10))}_#{n}".gsub("'", "_")
  end

  sequence(:hashtag_name) do |n|
    "#{Faker::Lorem.characters(number: rand(1..10))}_#{n}".gsub("'", "_")
  end

  sequence(:email) do |n|
    "user#{n}@example.org"
  end

  sequence(:slug) do |n|
    "#{Decidim::Faker::Internet.slug(words: nil, glue: "-")}-#{n}".gsub("'", "_")
  end

  sequence(:scope_name) do |n|
    "#{Faker::Lorem.sentence(word_count: 1, supplemental: true, random_words_to_add: 3)} #{n}".gsub("s", "z").gsub("S", "Z")
  end

  sequence(:scope_code) do |n|
    "#{Faker::Lorem.characters(number: 4).upcase}-#{n}"
  end

  sequence(:area_name) do |n|
    "#{Faker::Lorem.sentence(word_count: 1, supplemental: true, random_words_to_add: 3)} #{n}"
  end

  factory :category, class: "Decidim::Category" do
    transient do
      skip_injection { false }
    end

    name { generate_localized_title(:category_name, skip_injection:) }
    description { generate_localized_description(:category_description, skip_injection:) }
    weight { 0 }

    association :participatory_space, factory: :participatory_process
  end

  factory :subcategory, parent: :category do
    transient do
      skip_injection { false }
    end
    parent { build(:category, skip_injection:) }

    participatory_space { parent.participatory_space }
  end

  factory :organization, class: "Decidim::Organization" do
    transient do
      skip_injection { false }
      create_static_pages { true }
    end

    # we do not want machine translation here
    name do
      Decidim.available_locales.index_with { |_locale| Faker::Company.unique.name }
    end

    reference_prefix { Faker::Name.suffix }
    time_zone { "UTC" }
    twitter_handler { Faker::Hipster.word }
    facebook_handler { Faker::Hipster.word }
    instagram_handler { Faker::Hipster.word }
    youtube_handler { Faker::Hipster.word }
    github_handler { Faker::Hipster.word }
    sequence(:host) { |n| "#{n}.lvh.me" }
    description { generate_localized_description(:organization_description, skip_injection:) }
    favicon { Decidim::Dev.test_file("icon.png", "image/png") }
    default_locale { Decidim.default_locale }
    available_locales { Decidim.available_locales }
    users_registration_mode { :enabled }
    official_img_footer { Decidim::Dev.test_file("avatar.jpg", "image/jpeg") }
    official_url { Faker::Internet.url }
    highlighted_content_banner_enabled { false }
    enable_omnipresent_banner { false }
    badges_enabled { true }
    send_welcome_notification { true }
    comments_max_length { 1000 }
    admin_terms_of_service_body { generate_localized_description(:admin_terms_of_service_body, skip_injection:) }
    force_users_to_authenticate_before_access_organization { false }
    machine_translation_display_priority { "original" }
    external_domain_allowlist { ["example.org", "twitter.com", "facebook.com", "youtube.com", "github.com", "mytesturl.me"] }
    smtp_settings do
      {
        "from" => "test@example.org",
        "user_name" => "test",
        "encrypted_password" => Decidim::AttributeEncryptor.encrypt("demo"),
        "port" => "25",
        "address" => "smtp.example.org"
      }
    end
    file_upload_settings { Decidim::OrganizationSettings.default(:upload) }
    enable_participatory_space_filters { true }
    content_security_policy do
      {
        "default-src" => "localhost:* #{host}:*",
        "script-src" => "localhost:* #{host}:*",
        "style-src" => "localhost:* #{host}:*",
        "img-src" => "localhost:* #{host}:*",
        "font-src" => "localhost:* #{host}:*",
        "connect-src" => "localhost:* #{host}:*",
        "frame-src" => "localhost:* #{host}:* www.example.org",
        "media-src" => "localhost:* #{host}:*"
      }
    end
    colors do
      {
        primary: "#e02d2d",
        secondary: "#155abf",
        tertiary: "#ebc34b"
      }
    end

    trait :secure_context do
      host { "localhost" }
    end

    after(:create) do |organization, evaluator|
      if evaluator.create_static_pages
        tos_page = Decidim::StaticPage.find_by(slug: "terms-of-service", organization:)
        create(:static_page, :tos, organization:, skip_injection: evaluator.skip_injection) if tos_page.nil?
      end
    end
  end

  factory :user, class: "Decidim::User" do
    transient do
      skip_injection { false }
    end
    email { generate(:email) }
    name { generate(:name) }
    nickname { generate(:nickname) }
    organization
    locale { organization.default_locale }
    tos_agreement { "1" }
    avatar { Decidim::Dev.test_file("avatar.jpg", "image/jpeg") }
    personal_url { Faker::Internet.url }
    about { generate_localized_title(:user_about, skip_injection:) }
    confirmation_sent_at { Time.current }
    accepted_tos_version { organization.tos_version }
    notifications_sending_frequency { "real_time" }
    email_on_moderations { true }
    email_on_assigned_proposals { true }
    password_updated_at { Time.current }
    previous_passwords { [] }
    extended_data { {} }

    trait :confirmed do
      confirmed_at { Time.current }
    end

    trait :blocked do
      blocked { true }
      blocked_at { Time.current }
      extended_data { { user_name: generate(:name) } }
      name { "Blocked user" }
    end

    trait :deleted do
      name { "" }
      nickname { "" }
      email { "" }
      delete_reason { "I want to delete my account" }
      admin { false }
      deleted_at { Time.current }
      avatar { nil }
      personal_url { "" }
      about { "" }
    end

    trait :admin_terms_accepted do
      admin_terms_accepted_at { Time.current }
    end

    trait :admin do
      admin { true }
      admin_terms_accepted
    end

    trait :user_manager do
      roles { ["user_manager"] }
      admin_terms_accepted
    end

    trait :managed do
      email { "" }
      password { "" }
      encrypted_password { "" }
      managed { true }
    end

    trait :tos_not_accepted do
      accepted_tos_version { nil }
    end

    trait :ephemeral do
      managed
      extended_data { { ephemeral: true } }
    end

    trait :officialized do
      officialized_at { Time.current }
      officialized_as { generate_localized_title(:officialized_as, skip_injection:) }
    end

    after(:build) do |user, evaluator|
      # We have specs that call e.g. `create(:user, admin: true)` where we need
      # to do this to ensure the user creation does not fail due to the short
      # password.
      user.password ||= evaluator.password || "decidim123456789"
    end
  end

  factory :participatory_space_private_user, class: "Decidim::ParticipatorySpacePrivateUser" do
    transient do
      skip_injection { false }
    end
    user
    privatable_to { create(:participatory_process, organization: user.organization, skip_injection:) }

    role { generate_localized_title(:role, skip_injection:) }

    trait :unpublished do
      published { false }
    end

    trait :published do
      published { true }
    end
  end

  factory :assembly_private_user, class: "Decidim::ParticipatorySpacePrivateUser" do
    transient do
      skip_injection { false }
    end
    user
    privatable_to { create(:assembly, organization: user.organization, skip_injection:) }
  end

  factory :identity, class: "Decidim::Identity" do
    transient do
      skip_injection { false }
    end
    provider { "facebook" }
    sequence(:uid)
    user
    organization { user.organization }
  end

  factory :authorization, class: "Decidim::Authorization" do
    transient do
      skip_injection { false }
    end
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

  factory :authorization_transfer, class: "Decidim::AuthorizationTransfer" do
    transient do
      skip_injection { false }
      organization { create(:organization, skip_injection:) }
    end

    user { create(:user, :confirmed, organization:, skip_injection:) }
    source_user { create(:user, :confirmed, :deleted, organization: user.try(:organization) || organization, skip_injection:) }
    authorization do
      create(
        :authorization,
        user: source_user || create(:user, :confirmed, :deleted, organization: user.try(:organization) || organization, skip_injection:)
      )
    end

    trait :transferred do
      authorization { create(:authorization, user:, skip_injection:) }
    end
  end

  factory :authorization_transfer_record, class: "Decidim::AuthorizationTransferRecord" do
    transient do
      skip_injection { false }
      organization { resource.try(:organization) || create(:organization, skip_injection:) }
    end

    transfer { create(:authorization_transfer, organization:, skip_injection:) }
    resource { create(:dummy_resource, skip_injection:) }
  end

  factory :static_page, class: "Decidim::StaticPage" do
    transient do
      skip_injection { false }
    end
    slug { generate(:slug) }
    title { generate_localized_title(:static_page_title, skip_injection:) }
    content { generate_localized_description(:static_page_content, skip_injection:) }
    organization { build(:organization, skip_injection:) }
    allow_public_access { false }

    trait :default do
      slug { Decidim::StaticPage::DEFAULT_PAGES.sample }
    end

    trait :public do
      allow_public_access { true }
    end

    trait :tos do
      slug { "terms-of-service" }
      after(:create) do |tos_page|
        tos_page.organization.tos_version = tos_page.updated_at
        tos_page.organization.save!
      end
    end

    trait :with_topic do
      after(:create) do |static_page, evaluator|
        topic = create(:static_page_topic, organization: static_page.organization, skip_injection: evaluator.skip_injection)
        static_page.topic = topic
        static_page.save
      end
    end
  end

  factory :static_page_topic, class: "Decidim::StaticPageTopic" do
    transient do
      skip_injection { false }
    end
    title { generate_localized_title(:static_page_topic_title, skip_injection:) }
    description { generate_localized_description(:static_page_topic_description, skip_injection:) }
    show_in_footer { true }
    organization
  end

  factory :attachment_collection, class: "Decidim::AttachmentCollection" do
    transient do
      skip_injection { false }
    end
    name { generate_localized_title(:attachment_collection_name, skip_injection:) }
    description { generate_localized_title(:attachment_collection_description, skip_injection:) }
    weight { Faker::Number.number(digits: 1) }

    association :collection_for, factory: :participatory_process
  end

  factory :attachment, class: "Decidim::Attachment" do
    transient do
      skip_injection { false }
    end
    title { generate_localized_title(:attachment_title, skip_injection:) }
    description { generate_localized_title(:attachment_description, skip_injection:) }
    weight { Faker::Number.number(digits: 1) }
    attached_to { build(:participatory_process, skip_injection:) }
    content_type { "image/jpeg" }
    file { Decidim::Dev.test_file("city.jpeg", "image/jpeg") } # Keep after attached_to
    file_size { 108_908 }

    trait :with_image do
      file { Decidim::Dev.test_file("city.jpeg", "image/jpeg") }
    end

    trait :with_pdf do
      file { Decidim::Dev.test_file("Exampledocument.pdf", "application/pdf") }
      content_type { "application/pdf" }
      file_size { 17_525 }
    end

    trait :with_link do
      file { nil }
      link { Faker::Internet.url }
    end
  end

  factory :component, class: "Decidim::Component" do
    transient do
      skip_injection { false }
      organization { create(:organization, skip_injection:) }
    end

    name { generate_localized_title(:component_name, skip_injection:) }
    participatory_space { create(:participatory_process, organization:, skip_injection:) }
    manifest_name { "dummy" }
    published_at { Time.current }
    deleted_at { nil }
    settings do
      {
        dummy_global_translatable_text: generate_localized_title(:dummy_global_translatable_text, skip_injection:),
        comments_max_length: participatory_space.organization.comments_max_length || organization.comments_max_length
      }
    end

    default_step_settings do
      {
        dummy_step_translatable_text: generate_localized_title(:dummy_step_translatable_text, skip_injection:)
      }
    end

    trait :with_one_step do
      step_settings do
        participatory_space_with_steps if participatory_space.active_step.nil?
        {
          participatory_space.active_step.id => { dummy_step_setting: true }
        }
      end
    end

    trait :unpublished do
      published_at { nil }
    end

    trait :published do
      published_at { Time.current }
    end

    trait :trashed do
      deleted_at { Time.current }
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

    transient do
      participatory_space_with_steps do
        create(:participatory_process_step,
               active: true,
               end_date: 1.month.from_now,
               participatory_process: participatory_space,
               skip_injection:)
        participatory_space.reload
        participatory_space.steps.reload
      end
    end

    trait :with_likes_enabled do
      step_settings do
        participatory_space_with_steps if participatory_space.active_step.nil?
        {
          participatory_space.active_step.id => { likes_enabled: true }
        }
      end
    end

    trait :with_likes_disabled do
      step_settings do
        participatory_space_with_steps if participatory_space.active_step.nil?
        {
          participatory_space.active_step.id => { likes_enabled: false }
        }
      end
    end

    trait :with_likes_blocked do
      step_settings do
        participatory_space_with_steps if participatory_space.active_step.nil?
        {
          participatory_space.active_step.id => { likes_blocked: true }
        }
      end
    end

    trait :with_comments_disabled do
      settings do
        {
          comments_enabled: false
        }
      end
    end
  end

  factory :scope_type, class: "Decidim::ScopeType" do
    transient do
      skip_injection { false }
    end
    name { generate_localized_word(:scope_type_name, skip_injection:) }
    plural { Decidim::Faker::Localized.literal(name.values.first.pluralize) }
    organization
  end

  factory :scope, class: "Decidim::Scope" do
    transient do
      skip_injection { false }
    end
    name { Decidim::Faker::Localized.literal(generate(:scope_name)) }
    code { generate(:scope_code) }
    scope_type { create(:scope_type, organization:, skip_injection:) }
    organization { parent ? parent.organization : build(:organization, skip_injection:) }
  end

  factory :subscope, parent: :scope do
    transient do
      skip_injection { false }
    end
    parent { build(:scope, skip_injection:) }

    before(:create) do |object|
      object.parent.save unless object.parent.persisted?
    end
  end

  factory :area_type, class: "Decidim::AreaType" do
    transient do
      skip_injection { false }
    end
    name { generate_localized_word(:area_type_name, skip_injection:) }
    plural { Decidim::Faker::Localized.literal(name.values.first.pluralize) }
    organization
  end

  factory :area, class: "Decidim::Area" do
    transient do
      skip_injection { false }
    end
    name { Decidim::Faker::Localized.literal(generate(:area_name)) }
    organization
  end

  factory :taxonomy, class: "Decidim::Taxonomy" do
    transient do
      skip_injection { false }
    end

    name { generate_localized_title(:taxonomy_name, skip_injection:) }
    organization
    parent { nil }
    weight { nil }

    trait :with_parent do
      parent { create(:taxonomy, organization:, skip_injection:) }
    end

    trait :with_children do
      transient do
        children_count { 3 }
      end

      after(:create) do |taxonomy, evaluator|
        create_list(:taxonomy, evaluator.children_count, parent: taxonomy, organization: taxonomy.organization)
      end
    end
  end

  factory :taxonomization, class: "Decidim::Taxonomization" do
    taxonomy { association(:taxonomy, :with_parent) }
    taxonomizable { association(:dummy_resource) }
  end

  factory :taxonomy_filter, class: "Decidim::TaxonomyFilter" do
    root_taxonomy { association(:taxonomy) }
    participatory_space_manifests { ["participatory_processes"] }

    trait :with_items do
      transient do
        items_count { 3 }
      end

      after(:create) do |taxonomy_filter, evaluator|
        create_list(:taxonomy_filter_item, evaluator.items_count, taxonomy_filter:)
      end
    end
  end

  factory :taxonomy_filter_item, class: "Decidim::TaxonomyFilterItem" do
    taxonomy_filter
    taxonomy_item { association(:taxonomy, parent: taxonomy_filter.root_taxonomy) }
  end

  factory :coauthorship, class: "Decidim::Coauthorship" do
    transient do
      skip_injection { false }
    end
    coauthorable { create(:dummy_resource, skip_injection:) }
    transient do
      organization { coauthorable.component.participatory_space.organization }
    end
    author { create(:user, :confirmed, organization:, skip_injection:) }
  end

  factory :resource_link, class: "Decidim::ResourceLink" do
    transient do
      skip_injection { false }
    end
    name { generate(:slug) }
    to { build(:dummy_resource, skip_injection:) }
    from { build(:dummy_resource, component: to.component, skip_injection:) }
  end

  factory :newsletter, class: "Decidim::Newsletter" do
    transient do
      skip_injection { false }
      body { generate_localized_description(:newsletter_body, skip_injection:) }
    end

    author { build(:user, :confirmed, organization:, skip_injection:) }
    organization

    subject { generate_localized_title }

    after(:create) do |newsletter, evaluator|
      create(
        :content_block,
        :newsletter_template,
        organization: evaluator.organization,
        scoped_resource_id: newsletter.id,
        manifest_name: "basic_only_text",
        settings: evaluator.body.transform_keys { |key| "body_#{key}" },
        skip_injection: evaluator.skip_injection
      )
    end

    trait :sent do
      sent_at { Time.current }
    end
  end

  factory :moderation, class: "Decidim::Moderation" do
    transient do
      skip_injection { false }
    end
    reportable { build(:dummy_resource, skip_injection:) }
    participatory_space { reportable.component.participatory_space }

    trait :hidden do
      hidden_at { 1.day.ago }
    end
  end

  factory :report, class: "Decidim::Report" do
    transient do
      skip_injection { false }
    end
    moderation
    user { build(:user, organization: moderation.reportable.organization, skip_injection:) }
    reason { "spam" }
  end

  factory :impersonation_log, class: "Decidim::ImpersonationLog" do
    transient do
      skip_injection { false }
    end
    admin { build(:user, :admin, skip_injection:) }
    user { build(:user, :managed, organization: admin.organization, skip_injection:) }
    started_at { 10.minutes.ago }
  end

  factory :follow, class: "Decidim::Follow" do
    transient do
      skip_injection { false }
    end
    user do
      build(
        :user,
        organization: followable.try(:organization) || build(:organization, skip_injection:)
      )
    end
    followable { build(:dummy_resource, skip_injection:) }
  end

  factory :notification, class: "Decidim::Notification" do
    transient do
      skip_injection { false }
    end
    user do
      build(
        :user,
        organization: resource.try(:organization) || build(:organization, skip_injection:)
      )
    end
    resource { build(:dummy_resource, skip_injection:) }
    event_name { resource.class.name.underscore.tr("/", ".") }
    event_class { "Decidim::Dev::DummyResourceEvent" }
    extra do
      {
        some_extra_data: "1"
      }
    end

    trait :proposal_coauthor_invite do
      event_name { "decidim.events.proposals.coauthor_invited" }
      event_class { "Decidim::Proposals::CoauthorInvitedEvent" }
    end
  end

  factory :conversation, class: "Decidim::Messaging::Conversation" do
    transient do
      skip_injection { false }
    end

    originator { build(:user, skip_injection:) }
    interlocutors { [build(:user, skip_injection:)] }
    body { Faker::Lorem.sentence }
    user

    after(:create) do |object|
      object.participants ||= [originator + interlocutors].flatten
    end

    initialize_with { Decidim::Messaging::Conversation.start(originator:, interlocutors:, body:, user:) }
  end

  factory :message, class: "Decidim::Messaging::Message" do
    transient do
      skip_injection { false }
    end

    body { generate_localized_description(:message_body, skip_injection:) }
    conversation

    before(:create) do |object|
      object.sender ||= object.conversation.participants.take
    end
  end

  factory :push_notification_message, class: "Decidim::PushNotificationMessage" do
    transient do
      skip_injection { false }
    end

    recipient { build(:user, skip_injection:) }
    conversation { create(:conversation, skip_injection:) }
    message { generate_localized_description(:push_notification_message_message, skip_injection:) }

    skip_create
    initialize_with { new(recipient:, conversation:, message:) }
  end

  factory :action_log, class: "Decidim::ActionLog" do
    transient do
      skip_injection { false }
      extra_data { {} }
    end

    user { create(:user) }
    organization { user.organization }
    user_id { user.id }
    user_type { user.class.name }
    participatory_space { build(:participatory_process, organization:, skip_injection:) }
    component { build(:component, participatory_space:, skip_injection:) }
    resource { build(:dummy_resource, component:, skip_injection:) }
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
    transient do
      skip_injection { false }
    end
    organization
    sequence(:name) { |n| "OAuth application #{n}" }
    sequence(:organization_name) { |n| "OAuth application owner #{n}" }
    organization_url { "http://example.org" }
    organization_logo { Decidim::Dev.test_file("avatar.jpg", "image/jpeg") }
    redirect_uri { "https://app.example.org/oauth" }
    scopes { "profile" }
    confidential { true }
    refresh_tokens_enabled { false }
  end

  factory :oauth_access_token, class: "Doorkeeper::AccessToken" do
    transient do
      skip_injection { false }
    end
    resource_owner_id { create(:user, organization: application.organization, skip_injection:).id }
    application { build(:oauth_application, skip_injection:) }
    token { SecureRandom.hex(32) }
    expires_in { 1.month.from_now }
    created_at { Time.current }
    scopes { "profile" }
  end

  factory :private_export, class: "Decidim::PrivateExport" do
    transient do
      skip_injection { false }
      organization { create(:organization) }
    end
    expires_at { 1.week.from_now }
    attached_to { create(:user, organization:, skip_injection:) }
    export_type { "dummy" }
    content_type { "application/zip" }
    file_size { 10.kilobytes }
  end

  factory :searchable_resource, class: "Decidim::SearchableResource" do
    transient do
      skip_injection { false }
    end
    resource { build(:dummy_resource, skip_injection:) }
    resource_id { resource.id }
    resource_type { resource.class.name }
    organization { resource.component.organization }
    decidim_participatory_space { resource.component.participatory_space }
    locale { I18n.locale }
    content_a { Faker::Lorem.sentence }
    datetime { Time.current }
  end

  factory :content_block, class: "Decidim::ContentBlock" do
    transient do
      skip_injection { false }
    end
    organization
    scope_name { :homepage }
    manifest_name { :hero }
    weight { 1 }
    published_at { Time.current }

    trait :newsletter_template do
      scope_name { :newsletter_template }
      manifest_name { :basic_only_text }
    end
  end

  factory :hashtag, class: "Decidim::Hashtag" do
    transient do
      skip_injection { false }
    end
    name { generate(:hashtag_name) }
    organization
  end

  factory :amendment, class: "Decidim::Amendment" do
    transient do
      skip_injection { false }
    end
    amendable { build(:dummy_resource, skip_injection:) }
    emendation { build(:dummy_resource, skip_injection:) }
    amender { emendation.try(:creator_author) || emendation.try(:author) }
    state { "evaluating" }

    Decidim::Amendment::STATES.keys.each do |defined_state|
      trait defined_state do
        state { defined_state }
      end
    end
  end

  factory :user_block, class: "Decidim::UserBlock" do
    transient do
      organization { create(:organization) }
      blocked_at { Time.current }
    end
    justification { generate(:title) }
    blocking_user { create(:user, :admin, :confirmed, organization:) }
    user { create(:user, :blocked, :confirmed, organization:) }

    after(:create) do |object, evaluator|
      object.user.block_id = object.id
      object.user.blocked_at = evaluator.blocked_at
      object.user.save!
    end
  end

  factory :user_report, class: "Decidim::UserReport" do
    transient do
      skip_injection { false }
    end
    reason { "spam" }
    moderation { create(:user_moderation, user:, skip_injection:) }
    user { build(:user) }
  end

  factory :user_moderation, class: "Decidim::UserModeration" do
    transient do
      skip_injection { false }
    end
    user { create(:user, :confirmed) }
  end

  factory :like, class: "Decidim::Like" do
    transient do
      skip_injection { false }
    end
    resource { build(:dummy_resource, skip_injection:) }
    author { resource.try(:creator_author) || resource.try(:author) || build(:user, organization: resource.organization, skip_injection:) }
  end

  factory :share_token, class: "Decidim::ShareToken" do
    transient do
      skip_injection { false }
    end
    token_for { build(:component, skip_injection:) }
    user { build(:user, organization: token_for.organization, skip_injection:) }

    before(:create) do |object|
      object.organization ||= object.token_for.organization
    end

    trait :with_token do
      token { SecureRandom.hex(32) }
    end

    trait :expired do
      expires_at { 1.day.ago }
    end

    trait :used do
      times_used { 3 }
      last_used_at { 1.hour.ago }
    end
  end

  factory :editor_image, class: "Decidim::EditorImage" do
    transient do
      skip_injection { false }
    end
    organization
    author { create(:user, :admin, :confirmed, organization:, skip_injection:) }
    file { Decidim::Dev.test_file("city.jpeg", "image/jpeg") }
  end

  factory :reminder, class: "Decidim::Reminder" do
    transient do
      skip_injection { false }
    end
    user { build(:user, skip_injection:) }
    component { build(:dummy_component, organization: user.organization, skip_injection:) }
  end

  factory :reminder_record, class: "Decidim::ReminderRecord" do
    transient do
      skip_injection { false }
    end
    reminder { create(:reminder, skip_injection:) }
    remindable { build(:dummy_resource, skip_injection:) }

    Decidim::ReminderRecord::STATES.keys.each do |defined_state|
      trait defined_state do
        state { defined_state }
      end
    end
  end

  factory :reminder_delivery, class: "Decidim::ReminderDelivery" do
    transient do
      skip_injection { false }
    end
    reminder { create(:reminder, skip_injection:) }
  end

  factory :short_link, class: "Decidim::ShortLink" do
    transient do
      skip_injection { false }
    end
    target { create(:component, manifest_name: "dummy", skip_injection:) }
    route_name { nil }
    params { {} }

    before(:create) do |object, evaluator|
      object.organization ||= object.target if object.target.is_a?(Decidim::Organization)
      object.organization ||= object.target.try(:organization) || create(:organization, skip_injection: evaluator.skip_injection)
      object.identifier ||= Decidim::ShortLink.unique_identifier_within(object.organization)
      object.mounted_engine_name ||=
        if object.target.respond_to?(:participatory_space)
          "decidim_#{object.target.participatory_space.underscored_name}_dummy"
        else
          "decidim"
        end
    end
  end

  factory :blob, class: "ActiveStorage::Blob" do
    transient do
      filepath { Decidim::Dev.asset("city.jpeg") }
    end

    filename { File.basename(filepath) }
    content_type { MiniMime.lookup_by_filename(filepath)&.content_type || "text/plain" }

    before(:create) do |object, evaluator|
      object.upload(File.open(evaluator.filepath))
    end

    trait :image do
      filepath { Decidim::Dev.asset("city.jpeg") }
    end

    trait :document do
      filepath { Decidim::Dev.asset("Exampledocument.pdf") }
    end
  end
end
