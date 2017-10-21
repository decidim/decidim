# frozen_string_literal: true

require "decidim/core/test/factories"
require "decidim/participatory_processes/test/factories"

FactoryBot.define do
  factory :proposal_feature, parent: :feature do
    name { Decidim::Features::Namer.new(participatory_space.organization.available_locales, :proposals).i18n_name }
    manifest_name :proposals
    participatory_space { create(:participatory_process, :with_steps, organization: organization) }

    trait :with_votes_enabled do
      step_settings do
        {
          participatory_space.active_step.id => { votes_enabled: true }
        }
      end
    end

    trait :with_votes_disabled do
      step_settings do
        {
          participatory_space.active_step.id => { votes_enabled: false }
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

    trait :with_proposal_limit do
      transient do
        proposal_limit 1
      end

      settings do
        {
          proposal_limit: proposal_limit
        }
      end
    end

    trait :with_votes_blocked do
      step_settings do
        {
          participatory_space.active_step.id => {
            votes_enabled: true,
            votes_blocked: true
          }
        }
      end
    end

    trait :with_creation_enabled do
      step_settings do
        {
          participatory_space.active_step.id => { creation_enabled: true }
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

    trait :with_attachments_allowed do
      settings do
        {
          attachments_allowed: true
        }
      end
    end

    trait :with_maximum_votes_per_proposal do
      settings do
        {
          maximum_votes_per_proposal: 1
        }
      end
    end
  end

  factory :proposal, class: "Decidim::Proposals::Proposal" do
    title { Faker::Lorem.sentence }
    body { Faker::Lorem.sentences(3).join("\n") }
    feature { create(:proposal_feature) }
    author do
      create(:user, organization: feature.organization) if feature
    end

    trait :official do
      author nil
    end

    trait :evaluating do
      state "evaluating"
      answered_at { Time.current }
    end

    trait :accepted do
      state "accepted"
      answered_at { Time.current }
    end

    trait :rejected do
      state "rejected"
      answered_at { Time.current }
    end

    trait :with_answer do
      answer { Decidim::Faker::Localized.sentence }
      answered_at { Time.current }
    end
  end

  factory :proposal_vote, class: "Decidim::Proposals::ProposalVote" do
    proposal { build(:proposal) }
    author { build(:user, organization: proposal.organization) }
  end
end
