# frozen_string_literal: true
require "decidim/core/test/factories"
require "decidim/admin/test/factories"
require "decidim/comments/test/factories"
require "decidim/meetings/test/factories"
require "decidim/results/test/factories"
require "decidim/budgets/test/factories"

FactoryGirl.define do
  factory :proposal_feature, parent: :feature do
    name { Decidim::Features::Namer.new(participatory_process.organization.available_locales, :proposals).i18n_name }
    manifest_name :proposals
    participatory_process { create(:participatory_process, :with_steps) }

    trait :with_votes_enabled do
      step_settings do
        {
          participatory_process.active_step.id => { votes_enabled: true }
        }
      end
    end

    trait :with_vote_limit do
      transient do
        vote_limit 10
      end

      settings do
        {
          vote_limit: vote_limit
        }
      end
    end

    trait :with_votes_blocked do
      step_settings do
        {
          participatory_process.active_step.id => {
            votes_enabled: true,
            votes_blocked: true
          }
        }
      end
    end

    trait :with_creation_enabled do
      step_settings do
        {
          participatory_process.active_step.id => { creation_enabled: true }
        }
      end
    end

    trait :with_geocoding_enabled do
      settings do
        {
          geocoding_enabled: true
        }
      end
    end
  end

  factory :proposal, class: Decidim::Proposals::Proposal do
    title { Faker::Lorem.sentence }
    body { Faker::Lorem.sentences(3).join("\n") }
    feature { create(:proposal_feature) }
    author do
      create(:user, organization: feature.organization) if feature
    end

    trait :official do
      author nil
    end

    trait :accepted do
      state "accepted"
      answered_at { Time.current }
    end

    trait :rejected do
      state "rejected"
      answer { Decidim::Faker::Localized.sentence }
      answered_at { Time.current }
    end
  end

  factory :proposal_vote, class: Decidim::Proposals::ProposalVote do
    proposal { build(:proposal) }
    author { build(:user, organization: proposal.organization) }
  end
end
