# frozen_string_literal: true

require "decidim/faker/localized"
require "decidim/dev"

FactoryBot.define do
  factory :initiatives_type, class: "Decidim::InitiativesType" do
    title { generate_localized_title }
    description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title } }
    banner_image { Decidim::Dev.test_file("city2.jpeg", "image/jpeg") }
    organization
    signature_type { :online }
    attachments_enabled { true }
    undo_online_signatures_enabled { true }
    custom_signature_end_date_enabled { false }
    promoting_committee_enabled { true }
    minimum_committee_members { 3 }

    trait :attachments_enabled do
      attachments_enabled { true }
    end

    trait :attachments_disabled do
      attachments_enabled { false }
    end

    trait :online_signature_enabled do
      signature_type { :online }
    end

    trait :online_signature_disabled do
      signature_type { :offline }
    end

    trait :undo_online_signatures_enabled do
      undo_online_signatures_enabled { true }
    end

    trait :undo_online_signatures_disabled do
      undo_online_signatures_enabled { false }
    end

    trait :custom_signature_end_date_enabled do
      custom_signature_end_date_enabled { true }
    end

    trait :custom_signature_end_date_disabled do
      custom_signature_end_date_enabled { false }
    end

    trait :promoting_committee_enabled do
      promoting_committee_enabled { true }
    end

    trait :promoting_committee_disabled do
      promoting_committee_enabled { false }
      minimum_committee_members { 0 }
    end

    trait :with_user_extra_fields_collection do
      collect_user_extra_fields { true }
      extra_fields_legal_information { Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title } }
    end

    trait :with_sms_code_validation do
      validate_sms_code_on_votes { true }
    end
  end

  factory :initiatives_type_scope, class: "Decidim::InitiativesTypeScope" do
    type { create(:initiatives_type) }
    scope { create(:scope, organization: type.organization) }
    supports_required { 1000 }

    trait :with_user_extra_fields_collection do
      type { create(:initiatives_type, :with_user_extra_fields_collection) }
    end
  end

  factory :initiative, class: "Decidim::Initiative" do
    title { generate_localized_title }
    description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title } }
    organization
    author { create(:user, :confirmed, organization: organization) }
    published_at { Time.current }
    state { "published" }
    signature_type { "online" }
    signature_start_date { Date.current - 1.day }
    signature_end_date { Date.current + 120.days }

    scoped_type do
      create(:initiatives_type_scope,
             type: create(:initiatives_type, organization: organization, signature_type: signature_type))
    end

    after(:create) do |initiative|
      if initiative.author.is_a?(Decidim::User) && Decidim::Authorization.where(user: initiative.author).where.not(granted_at: nil).none?
        create(:authorization, user: initiative.author, granted_at: Time.now.utc)
      end
      create_list(:initiatives_committee_member, 3, initiative: initiative)
    end

    trait :created do
      state { "created" }
      published_at { nil }
      signature_start_date { nil }
      signature_end_date { nil }
    end

    trait :validating do
      state { "validating" }
      published_at { nil }
      signature_start_date { nil }
      signature_end_date { nil }
    end

    trait :published do
      state { "published" }
    end

    trait :unpublished do
      published_at { nil }
    end

    trait :accepted do
      state { "accepted" }
    end

    trait :discarded do
      state { "discarded" }
    end

    trait :rejected do
      state { "rejected" }
    end

    trait :online do
      signature_type { "online" }
    end

    trait :offline do
      signature_type { "offline" }
    end

    trait :acceptable do
      signature_start_date { Date.current - 3.months }
      signature_end_date { Date.current - 2.months }
      signature_type { "online" }

      after(:build) do |initiative|
        initiative.initiative_votes_count = initiative.scoped_type.supports_required + 1
      end
    end

    trait :rejectable do
      signature_start_date { Date.current - 3.months }
      signature_end_date { Date.current - 2.months }
      signature_type { "online" }

      after(:build) do |initiative|
        initiative.initiative_votes_count = initiative.scoped_type.supports_required - 1
      end
    end

    trait :with_user_extra_fields_collection do
      scoped_type do
        create(:initiatives_type_scope,
               type: create(:initiatives_type, :with_user_extra_fields_collection, organization: organization))
      end
    end
  end

  factory :initiative_user_vote, class: "Decidim::InitiativesVote" do
    initiative { create(:initiative) }
    author { create(:user, :confirmed, organization: initiative.organization) }
  end

  factory :organization_user_vote, class: "Decidim::InitiativesVote" do
    initiative { create(:initiative) }
    author { create(:user, :confirmed, organization: initiative.organization) }
    decidim_user_group_id { create(:user_group).id }
    after(:create) do |support|
      create(:user_group_membership, user: support.author, user_group: Decidim::UserGroup.find(support.decidim_user_group_id))
    end
  end

  factory :initiatives_committee_member, class: "Decidim::InitiativesCommitteeMember" do
    initiative { create(:initiative) }
    user { create(:user, :confirmed, organization: initiative.organization) }
    state { "accepted" }

    trait :accepted do
      state { "accepted" }
    end

    trait :requested do
      state { "requested" }
    end

    trait :rejected do
      state { "rejected" }
    end
  end
end
