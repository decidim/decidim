# frozen_string_literal: true

require "decidim/faker/localized"
require "decidim/dev"

FactoryBot.define do
  factory :initiatives_type, class: Decidim::InitiativesType do
    title { Decidim::Faker::Localized.sentence(3) }
    description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(4) } }
    banner_image { Decidim::Dev.test_file("city2.jpeg", "image/jpeg") }
    organization
  end

  factory :initiatives_type_scope, class: Decidim::InitiativesTypeScope do
    type { create(:initiatives_type) }
    scope { create(:scope, organization: type.organization) }
    supports_required { 1000 }
  end

  factory :initiative, class: Decidim::Initiative do
    title { Decidim::Faker::Localized.sentence(3) }
    description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(4) } }
    organization
    author { create(:user, :confirmed, organization: organization) }
    published_at { Time.current }
    state { "published" }
    signature_type { "online" }
    signature_start_date { Date.current - 1.day }
    signature_end_date { Date.current + 120.days }

    scoped_type do
      create(:initiatives_type_scope,
             type: create(:initiatives_type, organization: organization))
    end

    after(:create) do |initiative|
      create(:authorization, user: initiative.author, granted_at: Time.now.utc) unless Decidim::Authorization.where(user: initiative.author).where.not(granted_at: nil).any?
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
  end

  factory :initiative_user_vote, class: Decidim::InitiativesVote do
    initiative { create(:initiative) }
    author { create(:user, :confirmed, organization: initiative.organization) }
  end

  factory :organization_user_vote, class: Decidim::InitiativesVote do
    initiative { create(:initiative) }
    author { create(:user, :confirmed, organization: initiative.organization) }
    decidim_user_group_id { create(:user_group).id }
    after(:create) do |support|
      create(:user_group_membership, user: support.author, user_group: Decidim::UserGroup.find(support.decidim_user_group_id))
    end
  end

  factory :initiatives_committee_member, class: Decidim::InitiativesCommitteeMember do
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
