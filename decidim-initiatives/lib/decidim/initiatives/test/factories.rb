# frozen_string_literal: true

require "decidim/faker/localized"
require "decidim/dev"

FactoryBot.define do
  factory :initiatives_type, class: "Decidim::InitiativesType" do
    transient do
      skip_injection { false }
    end
    title { generate_localized_title(:initiatives_type_title, skip_injection:) }
    description { generate_localized_description(:initiatives_type_description, skip_injection:) }
    organization
    # Keep banner_image after organization
    banner_image do
      ActiveStorage::Blob.create_and_upload!(
        io: File.open(Decidim::Dev.test_file("city2.jpeg", "image/jpeg")),
        filename: "city2.jpeg",
        content_type: "image/jpeg"
      ).signed_id
    end
    signature_type { :online }
    attachments_enabled { true }
    undo_online_signatures_enabled { true }
    custom_signature_end_date_enabled { false }
    area_enabled { false }
    promoting_committee_enabled { true }
    minimum_committee_members { 3 }
    child_scope_threshold_enabled { false }
    only_global_scope_enabled { false }
    comments_enabled { true }

    trait :with_comments_disabled do
      comments_enabled { false }
    end

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

    trait :area_enabled do
      area_enabled { true }
    end

    trait :area_disabled do
      area_enabled { false }
    end

    trait :promoting_committee_enabled do
      promoting_committee_enabled { true }
    end

    trait :promoting_committee_disabled do
      promoting_committee_enabled { false }
      minimum_committee_members { 0 }
    end

    trait :with_user_extra_fields_collection do
      extra_fields_legal_information { generate_localized_description(:initiatives_type_extra_fields_legal_information, skip_injection:) }
      document_number_authorization_handler { "dummy_signature_with_personal_data_handler" }
    end

    trait :with_sms_code_validation do
      document_number_authorization_handler { "dummy_signature_with_sms_handler" }
    end

    trait :with_sms_code_validation_and_user_extra_fields_collection do
      extra_fields_legal_information { generate_localized_description(:initiatives_type_extra_fields_legal_information, skip_injection:) }
      document_number_authorization_handler { "dummy_signature_handler" }
    end

    trait :child_scope_threshold_enabled do
      child_scope_threshold_enabled { true }
    end

    trait :only_global_scope_enabled do
      only_global_scope_enabled { true }
    end
  end

  factory :initiatives_type_scope, class: "Decidim::InitiativesTypeScope" do
    transient do
      skip_injection { false }
    end
    type { create(:initiatives_type, skip_injection:) }
    scope { create(:scope, organization: type.organization, skip_injection:) }
    taxonomy { create(:taxonomy, organization: type.organization, skip_injection:) }
    supports_required { 1000 }

    trait :with_user_extra_fields_collection do
      type { create(:initiatives_type, :with_user_extra_fields_collection, skip_injection:) }
    end
  end

  factory :initiative, class: "Decidim::Initiative" do
    transient do
      skip_injection { false }
    end

    title { generate_localized_title(:initiative_title, skip_injection:) }
    description { generate_localized_description(:initiative_description, skip_injection:) }
    organization
    author { create(:user, :confirmed, organization:, skip_injection:) }
    state { "open" }
    published_at { Time.current.utc }
    signature_type { "online" }
    signature_start_date { Date.current - 1.day }
    signature_end_date { Date.current + 120.days }

    scoped_type do
      create(:initiatives_type_scope, skip_injection:,
                                      type: create(:initiatives_type, organization:, signature_type:, skip_injection:))
    end

    after(:create) do |initiative, evaluator|
      if initiative.author.is_a?(Decidim::User) && Decidim::Authorization.where(user: initiative.author).where.not(granted_at: nil).none?
        create(:authorization, user: initiative.author, granted_at: Time.now.utc, skip_injection: evaluator.skip_injection)
      end
      create_list(:initiatives_committee_member, 3, initiative:, skip_injection: evaluator.skip_injection)
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

    trait :open do
      state { "open" }
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
        initiative.online_votes[initiative.scope.id.to_s] = initiative.supports_required + 1
        initiative.online_votes["total"] = initiative.supports_required + 1
      end
    end

    trait :rejectable do
      signature_start_date { Date.current - 3.months }
      signature_end_date { Date.current - 2.months }
      signature_type { "online" }

      after(:build) do |initiative|
        initiative.online_votes[initiative.scope.id.to_s] = 0
        initiative.online_votes["total"] = 0
      end
    end

    trait :with_user_extra_fields_collection do
      scoped_type do
        create(:initiatives_type_scope, skip_injection:,
                                        type: create(:initiatives_type, :with_user_extra_fields_collection, organization:, skip_injection:))
      end
    end

    trait :with_area do
      area { create(:area, organization:, skip_injection:) }
    end

    trait :with_documents do
      transient do
        documents_number { 2 }
      end

      after :create do |initiative, evaluator|
        evaluator.documents_number.times do
          initiative.attachments << create(
            :attachment,
            :with_pdf,
            attached_to: initiative,
            skip_injection: evaluator.skip_injection
          )
        end
      end
    end

    trait :with_photos do
      transient do
        photos_number { 2 }
      end

      after :create do |initiative, evaluator|
        evaluator.photos_number.times do
          initiative.attachments << create(
            :attachment,
            :with_image,
            attached_to: initiative,
            skip_injection: evaluator.skip_injection
          )
        end
      end
    end
  end

  factory :initiative_user_vote, class: "Decidim::InitiativesVote" do
    transient do
      skip_injection { false }
    end
    initiative { create(:initiative, skip_injection:) }
    author { create(:user, :confirmed, organization: initiative.organization, skip_injection:) }
    hash_id { SecureRandom.uuid }
    scope { initiative.scope }
    after(:create) do |vote|
      vote.initiative.update_online_votes_counters
    end
  end

  factory :organization_user_vote, class: "Decidim::InitiativesVote" do
    transient do
      skip_injection { false }
    end
    initiative { create(:initiative, skip_injection:) }
    author { create(:user, :confirmed, organization: initiative.organization, skip_injection:) }
  end

  factory :initiatives_committee_member, class: "Decidim::InitiativesCommitteeMember" do
    transient do
      skip_injection { false }
    end
    initiative { create(:initiative, skip_injection:) }
    user { create(:user, :confirmed, organization: initiative.organization, skip_injection:) }
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

  factory :initiatives_settings, class: "Decidim::InitiativesSettings" do
    transient do
      skip_injection { false }
    end
    initiatives_order { "random" }
    organization

    trait :most_recent do
      initiatives_order { "date" }
    end

    trait :most_signed do
      initiatives_order { "signatures" }
    end

    trait :most_commented do
      initiatives_order { "comments" }
    end

    trait :most_recently_published do
      initiatives_order { "publication_date" }
    end
  end
end
