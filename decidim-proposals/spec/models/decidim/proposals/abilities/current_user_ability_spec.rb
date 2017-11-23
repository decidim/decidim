# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::Abilities::CurrentUserAbility do
  subject { described_class.new(user, context) }

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

  it { is_expected.to be_able_to(:report, Decidim::Proposals::Proposal) }

  describe "voting" do
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

  describe "unvoting" do
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

  describe "proposal creation" do
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

  describe "proposal edition" do
    let(:proposal) { build :proposal, author: user, created_at: Time.current, feature: proposal_feature }

    context "when proposal is editable" do
      before do
        allow(proposal).to receive(:editable_by?).and_return(true)
      end

      it { is_expected.to be_able_to(:edit, proposal) }
    end

    context "when proposal is not editable" do
      before do
        allow(proposal).to receive(:editable_by?).and_return(false)
      end

      it { is_expected.not_to be_able_to(:edit, proposal) }
    end
  end
end
