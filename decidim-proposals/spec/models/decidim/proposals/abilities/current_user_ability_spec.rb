# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::Abilities::CurrentUserAbility do
  subject { described_class.new(user, context) }

  let(:user) { build(:user) }
  let(:proposal_component) { create :proposal_component }
  let(:extra_context) do
    {
      current_settings: current_settings,
      component_settings: component_settings
    }
  end
  let(:context) do
    {
      current_component: proposal_component
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
  let(:component_settings) { double(proposal_edit_before_minutes: 5) }

  it { is_expected.to be_able_to(:report, Decidim::Proposals::Proposal) }

  describe "voting" do
    context "when voting is disabled" do
      let(:proposal) { build :proposal, component: proposal_component }
      let(:extra_settings) do
        {
          votes_enabled?: false,
          votes_blocked?: true
        }
      end

      it { is_expected.not_to be_able_to(:vote, proposal) }
    end

    context "when user is authorized" do
      let(:extra_settings) do
        {
          votes_enabled?: true,
          votes_blocked?: false
        }
      end

      it { is_expected.to be_able_to(:vote, Decidim::Proposals::Proposal) }
    end
  end

  describe "unvoting" do
    context "when voting is disabled" do
      let(:proposal) { build :proposal, component: proposal_component }
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
    let(:proposal) { build :proposal, author: user, created_at: Time.current, component: proposal_component }

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

    describe "withdrawing" do
      context "when user IS the same that created the proposal" do
        let(:proposal) { build :proposal, component: proposal_component, author: user }

        it { is_expected.to be_able_to(:withdraw, Decidim::Proposals::Proposal) }
      end

      context "when user is NOT the same that created the proposal" do
        let(:other_user) { create(:user, organization: proposal_component.organization) }
        let(:proposal) { build :proposal, component: proposal_component, author: other_user }

        it { is_expected.not_to be_able_to(:withdraw, proposal) }
      end
    end
  end

  describe "endorsing" do
    context "when endorsing is disabled" do
      let(:proposal) { build :proposal, component: proposal_component }
      let(:extra_settings) do
        {
          endorsements_enabled?: false,
          endorsements_blocked?: true
        }
      end

      it { is_expected.not_to be_able_to(:endorse, proposal) }
    end

    context "when user is authorized" do
      let(:extra_settings) do
        {
          endorsements_enabled?: true,
          endorsements_blocked?: false
        }
      end

      it { is_expected.to be_able_to(:endorse, Decidim::Proposals::Proposal) }
    end
  end

  describe "unendorsing" do
    context "when endorsing is disabled" do
      let(:proposal) { build :proposal, component: proposal_component }
      let(:extra_settings) do
        {
          endorsements_enabled?: false,
          endorsements_blocked?: true
        }
      end

      it { is_expected.not_to be_able_to(:unendorse, proposal) }
    end

    context "when user is authorized" do
      let(:extra_settings) do
        {
          endorsements_enabled?: true,
          endorsements_blocked?: false
        }
      end

      it { is_expected.to be_able_to(:unendorse, Decidim::Proposals::Proposal) }
    end
  end
end
