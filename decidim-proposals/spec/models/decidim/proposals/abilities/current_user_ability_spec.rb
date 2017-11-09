# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::Abilities::CurrentUserAbility do
  let(:user) { build(:user) }
  let(:proposal_feature) { create :proposal_feature }
  let(:extra_context) do
    {
      current_settings: current_settings,
      feature_settings: feature_settings
    }
  end
  let(:context) do
    {
      current_feature: proposal_feature
    }.merge(extra_context)
  end
  let(:settings) do
    {
      creation_enabled?: false,
      votes_enabled?: false,
      votes_blocked?: true
    }
  end
  let(:extra_settings) { {} }
  let(:current_settings) { double(settings.merge(extra_settings)) }
  let(:feature_settings) { double(proposal_edit_before_minutes: 5) }

  subject { described_class.new(user, context) }

  it { is_expected.to be_able_to(:report, Decidim::Proposals::Proposal) }

  context "voting" do
    context "when voting is disabled" do
      let(:proposal) { build :proposal, feature: proposal_feature }
      let(:extra_settings) do
        {
          votes_enabled?: false,
          votes_blocked?: true
        }
      end

      it { is_expected.not_to be_able_to(:unvote, proposal) }
    end

    context "when user is authorized" do
      let(:extra_settings) do
        {
          votes_enabled?: true,
          votes_blocked?: false
        }
      end

      it { is_expected.to be_able_to(:unvote, Decidim::Proposals::Proposal) }
    end
  end

  context "unvoting" do
    context "when voting is disabled" do
      let(:proposal) { build :proposal, feature: proposal_feature }
      let(:extra_settings) do
        {
          votes_enabled?: false,
          votes_blocked?: true
        }
      end

      it { is_expected.not_to be_able_to(:unvote, proposal) }
    end

    context "when user is authorized" do
      let(:extra_settings) do
        {
          votes_enabled?: true,
          votes_blocked?: false
        }
      end

      it { is_expected.to be_able_to(:unvote, Decidim::Proposals::Proposal) }
    end
  end

  context "creation" do
    context "when creation is disabled" do
      let(:extra_settings) do
        {
          creation_enabled?: false
        }
      end

      it { is_expected.not_to be_able_to(:create, Decidim::Proposals::Proposal) }
    end

    context "when user is authorized" do
      let(:extra_settings) do
        {
          creation_enabled?: true
        }
      end

      it { is_expected.to be_able_to(:create, Decidim::Proposals::Proposal) }
    end
  end

  context "edit proposal" do
    context "when user is author" do
      let(:proposal) { build :proposal, author: user, created_at: Time.current, feature: proposal_feature }

      it { is_expected.to be_able_to(:edit, proposal) }
    end

    context "when proposal is from user group and user is admin" do
      let(:user_group) { create :user_group, users: [user], organization: user.organization }
      let(:proposal) { build :proposal, created_at: Time.current, feature: proposal_feature, user_group: user_group }

      it { is_expected.to be_able_to(:edit, proposal) }
    end

    context "when user is not the author" do
      let(:proposal) { build :proposal, created_at: Time.current, feature: proposal_feature }

      it { is_expected.not_to be_able_to(:edit, proposal) }
    end

    context "when proposal is answered" do
      let(:proposal) { build :proposal, :with_answer, created_at: Time.current, author: user, feature: proposal_feature }

      it { is_expected.not_to be_able_to(:edit, proposal) }
    end

    context "when proposal editing time has run out" do
      let(:proposal) { build :proposal, created_at: 10.minutes.ago, author: user, feature: proposal_feature }

      it { is_expected.not_to be_able_to(:edit, proposal) }
    end
  end
end
