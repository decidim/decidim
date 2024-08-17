# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::Permissions do
  subject { described_class.new(user, permission_action, context).permissions.allowed? }

  let(:user) { proposal.creator_author }
  let(:context) do
    {
      current_component: proposal_component,
      current_settings:,
      proposal:,
      component_settings:,
      coauthor:
    }
  end
  let(:coauthor) { nil }
  let(:proposal_component) { create(:proposal_component) }
  let(:proposal) { create(:proposal, component: proposal_component) }
  let(:component_settings) do
    double(vote_limit: 2)
  end
  let(:current_settings) do
    double(settings.merge(extra_settings))
  end
  let(:settings) do
    {
      creation_enabled?: false
    }
  end
  let(:extra_settings) { {} }
  let(:permission_action) { Decidim::PermissionAction.new(**action) }

  context "when scope is admin" do
    let(:action) do
      { scope: :admin, action: :vote, subject: :proposal }
    end

    it_behaves_like "delegates permissions to", Decidim::Proposals::Admin::Permissions
  end

  context "when scope is not public" do
    let(:action) do
      { scope: :foo, action: :vote, subject: :proposal }
    end

    it_behaves_like "permission is not set"
  end

  context "when subject is not a proposal" do
    let(:action) do
      { scope: :public, action: :vote, subject: :foo }
    end

    it_behaves_like "permission is not set"
  end

  context "when creating a proposal" do
    let(:action) do
      { scope: :public, action: :create, subject: :proposal }
    end

    context "when creation is disabled" do
      let(:extra_settings) { { creation_enabled?: false } }

      it { is_expected.to be false }
    end

    context "when user is authorized" do
      let(:extra_settings) { { creation_enabled?: true } }

      it { is_expected.to be true }
    end
  end

  context "when editing a proposal" do
    let(:action) do
      { scope: :public, action: :edit, subject: :proposal }
    end

    before do
      allow(proposal).to receive(:editable_by?).with(user).and_return(editable)
    end

    context "when proposal is editable" do
      let(:editable) { true }

      it { is_expected.to be true }
    end

    context "when proposal is not editable" do
      let(:editable) { false }

      it { is_expected.to be false }
    end
  end

  context "when withdrawing a proposal" do
    let(:action) do
      { scope: :public, action: :withdraw, subject: :proposal }
    end

    context "when proposal author is the user trying to withdraw" do
      it { is_expected.to be true }
    end

    context "when trying by another user" do
      let(:user) { build(:user) }

      it { is_expected.to be false }
    end
  end

  describe "voting" do
    let(:action) do
      { scope: :public, action: :vote, subject: :proposal }
    end

    context "when voting is disabled" do
      let(:extra_settings) do
        {
          votes_enabled?: false,
          votes_blocked?: true
        }
      end

      it { is_expected.to be false }
    end

    context "when votes are blocked" do
      let(:extra_settings) do
        {
          votes_enabled?: true,
          votes_blocked?: true
        }
      end

      it { is_expected.to be false }
    end

    context "when the user has no more remaining votes" do
      let(:extra_settings) do
        {
          votes_enabled?: true,
          votes_blocked?: false
        }
      end

      before do
        proposals = create_list(:proposal, 2, component: proposal_component)
        create(:proposal_vote, author: user, proposal: proposals[0])
        create(:proposal_vote, author: user, proposal: proposals[1])
      end

      it { is_expected.to be false }
    end

    context "when the user is authorized" do
      let(:extra_settings) do
        {
          votes_enabled?: true,
          votes_blocked?: false
        }
      end

      it { is_expected.to be true }
    end
  end

  describe "unvoting" do
    let(:action) do
      { scope: :public, action: :unvote, subject: :proposal }
    end

    context "when voting is disabled" do
      let(:extra_settings) do
        {
          votes_enabled?: false,
          votes_blocked?: true
        }
      end

      it { is_expected.to be false }
    end

    context "when votes are blocked" do
      let(:extra_settings) do
        {
          votes_enabled?: true,
          votes_blocked?: true
        }
      end

      it { is_expected.to be false }
    end

    context "when the user is authorized" do
      let(:extra_settings) do
        {
          votes_enabled?: true,
          votes_blocked?: false
        }
      end

      it { is_expected.to be true }
    end
  end

  describe "amend" do
    let(:action) do
      { scope: :public, action: :amend, subject: :proposal }
    end

    context "when amend is disabled" do
      let(:extra_settings) do
        {
          amendments_enabled?: false
        }
      end

      it { is_expected.to be false }
    end

    context "when the user is authorized" do
      let(:extra_settings) do
        {
          amendments_enabled?: true
        }
      end

      it { is_expected.to be true }
    end
  end

  context "when inviting coauthor" do
    let(:action) do
      { scope: :public, action: :invite, subject: :proposal_coauthor_invites }
    end
    let(:coauthor) { create(:user, :confirmed, organization: user.organization) }
    let!(:comment) { create(:comment, commentable: proposal, author: coauthor) }

    shared_examples "coauthor is invitable" do
      it { is_expected.to be true }

      context "when already an author" do
        before do
          proposal.add_coauthor(coauthor)
        end

        it { is_expected.to be false }
      end

      context "when the current user is not the author" do
        let(:user) { create(:user, :confirmed, organization: proposal.organization) }

        it { is_expected.to be false }
      end

      context "when no comments" do
        let!(:comment) { nil }

        it { is_expected.to be false }
      end

      context "when coauthor not in comments" do
        let!(:comment) { create(:comment, commentable: proposal) }

        it { is_expected.to be false }
      end

      context "when coauthor is not confirmed" do
        let(:coauthor) { create(:user, organization: user.organization) }

        it { is_expected.to be false }
      end

      context "when coauthor is blocked" do
        let(:coauthor) { create(:user, :blocked, organization: user.organization) }

        it { is_expected.to be false }
      end

      context "when coauthor is deleted" do
        let(:coauthor) { create(:user, :deleted, organization: user.organization) }

        it { is_expected.to be false }
      end
    end

    it_behaves_like "coauthor is invitable"

    context "when a notification for the coauthor already exists" do
      let!(:notification) { create(:notification, :proposal_coauthor_invite, user: coauthor) }

      it { is_expected.to be true }
    end

    context "when notification exists for the same proposal" do
      let!(:notification) { create(:notification, :proposal_coauthor_invite, user: coauthor, resource: proposal) }

      it { is_expected.to be false }
    end

    context "when notification is for another user" do
      let!(:notification) { create(:notification, :proposal_coauthor_invite, resource: proposal) }

      it { is_expected.to be true }
    end

    context "when canceling invitation" do
      let(:action) do
        { scope: :public, action: :cancel, subject: :proposal_coauthor_invites }
      end
      let!(:notification) { create(:notification, :proposal_coauthor_invite, resource: proposal, user: coauthor) }

      it_behaves_like "coauthor is invitable"
    end
  end

  context "when coauthor is invited" do
    let(:action) do
      { scope: :public, action: :accept, subject: :proposal_coauthor_invites }
    end
    let(:user) { create(:user, :confirmed, organization: proposal.organization) }
    let(:coauthor) { user }
    let!(:notification) { create(:notification, :proposal_coauthor_invite, resource: proposal, user: coauthor) }

    shared_examples "can accept coauthor" do
      it { is_expected.to be true }

      context "when already an author" do
        before do
          proposal.add_coauthor(coauthor)
        end

        it { is_expected.to be false }
      end

      context "when the user is not the coauthor" do
        let(:coauthor) { create(:user, :confirmed, organization: proposal.organization) }

        it { is_expected.to be false }
      end

      context "when no invitation" do
        let!(:notification) { nil }

        it { is_expected.to be false }
      end

      context "when notification is not for the same proposal" do
        let!(:notification) { create(:notification, :proposal_coauthor_invite, user: coauthor) }

        it { is_expected.to be false }
      end

      context "when notification is for another coauthor" do
        let!(:notification) { create(:notification, :proposal_coauthor_invite, resource: proposal) }

        it { is_expected.to be false }
      end

      context "when coauthor is blocked" do
        let(:coauthor) { create(:user, :blocked, organization: proposal.organization) }

        it { is_expected.to be false }
      end

      context "when coauthor is deleted" do
        let(:coauthor) { create(:user, :deleted, organization: proposal.organization) }

        it { is_expected.to be false }
      end

      context "when coauthor is not confirmed" do
        let(:coauthor) { create(:user, organization: proposal.organization) }

        it { is_expected.to be false }
      end
    end

    it_behaves_like "can accept coauthor"

    context "when declining invitation" do
      let(:action) do
        { scope: :public, action: :decline, subject: :proposal_coauthor_invites }
      end

      it_behaves_like "can accept coauthor"
    end
  end
end
