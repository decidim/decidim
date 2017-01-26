require "decidim/core/test/factories"
require "decidim/admin/test/factories"
require "decidim/comments/test/factories"
require "decidim/meetings/test/factories"

FactoryGirl.define do
  factory :proposal_feature, class: Decidim::Feature do
    name { Decidim::Features::Namer.new(participatory_process.organization.available_locales, :proposals).i18n_name }
    manifest_name :proposals
    participatory_process

    trait :with_votes_enabled do
      step_settings do
        {
          participatory_process.active_step.id => { votes_enabled: true}
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
  end

  factory :proposal, class: Decidim::Proposals::Proposal do
    title { Faker::Lorem.sentence }
    body { Faker::Lorem.sentences(3).join("\n") }
    feature
    author { create(:user, organization: feature.organization) }
  end

  factory :proposal_vote, class: Decidim::Proposals::ProposalVote do
    proposal { build(:proposal) }
    author { build(:user, organization: proposal.organization) }
  end
end
