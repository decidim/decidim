# frozen_string_literal: true

require "spec_helper"

describe Decidim::Initiatives::Permissions do
  subject { described_class.new(user, permission_action, context).permissions.allowed? }

  let(:user) { create :user, organization: organization }
  let(:organization) { create :organization }
  let(:initiative) { create :initiative, organization: organization }
  let(:context) { {} }
  let(:permission_action) { Decidim::PermissionAction.new(action) }

  context "when reading the admin dashboard" do
    let(:action) do
      { scope: :admin, action: :read, subject: :admin_dashboard }
    end

    context "when user created an initiative" do
      let(:initiative) { create :initiative, author: user, organization: organization }

      before { initiative }

      it { is_expected.to eq true }
    end

    context "when user promoted an initiative" do
      before do
        create :initiatives_committee_member, initiative: initiative, user: user
      end

      it { is_expected.to eq true }
    end

    context "when any other condition" do
      it_behaves_like "permission is not set"
    end
  end

  context "when the action is for the admin part" do
    let(:action) do
      { scope: :admin, action: :foo, subject: :initiative }
    end

    it_behaves_like "delegates permissions to", Decidim::Initiatives::Admin::Permissions
  end

  context "when reading an initiative" do
    let(:initiative) { create :initiative, :discarded, organization: organization }
    let(:action) do
      { scope: :public, action: :read, subject: :initiative }
    end
    let(:context) do
      { initiative: initiative }
    end

    context "when initiative is published" do
      let(:initiative) { create :initiative, :published, organization: organization }

      it { is_expected.to eq true }
    end

    context "when initiative is rejected" do
      let(:initiative) { create :initiative, :rejected, organization: organization }

      it { is_expected.to eq true }
    end

    context "when initiative is accepted" do
      let(:initiative) { create :initiative, :accepted, organization: organization }

      it { is_expected.to eq true }
    end

    context "when user is admin" do
      let(:user) { create :user, :admin, organization: organization }

      it { is_expected.to eq true }
    end

    context "when user is author of the initiative" do
      let(:initiative) { create :initiative, author: user, organization: organization }

      it { is_expected.to eq true }
    end

    context "when user is committee member of the initiative" do
      before do
        create :initiatives_committee_member, initiative: initiative, user: user
      end

      it { is_expected.to eq true }
    end

    context "when any other condition" do
      it { is_expected.to eq false }
    end
  end

  context "when creating an initiative" do
    let(:action) do
      { scope: :public, action: :create, subject: :initiative }
    end

    context "when creation is enabled" do
      before do
        allow(Decidim::Initiatives)
          .to receive(:creation_enabled)
          .and_return(true)
      end

      it { is_expected.to eq false }

      context "when authorizations are not required" do
        before do
          allow(Decidim::Initiatives)
            .to receive(:do_not_require_authorization)
            .and_return(true)
        end

        it { is_expected.to eq true }
      end

      context "when user is authorized" do
        before do
          create :authorization, :granted, user: user
        end

        it { is_expected.to eq true }
      end

      context "when user belongs to a verified user group" do
        before do
          create :user_group, :verified, users: [user], organization: user.organization
        end

        it { is_expected.to eq true }
      end
    end

    context "when creation is not enabled" do
      before do
        allow(Decidim::Initiatives)
          .to receive(:creation_enabled)
          .and_return(false)
      end

      it { is_expected.to eq false }
    end
  end

  context "when requesting membership to an initiative" do
    let(:action) do
      { scope: :public, action: :request_membership, subject: :initiative }
    end
    let(:initiative) { create :initiative, :discarded, organization: organization }
    let(:context) do
      { initiative: initiative }
    end

    context "when initiative is published" do
      let(:initiative) { create :initiative, :published, organization: organization }

      it { is_expected.to eq false }
    end

    context "when initiative is not published" do
      context "when user is member" do
        let(:initiative) { create :initiative, :discarded, author: user, organization: organization }

        it { is_expected.to eq false }
      end

      context "when user is not a member" do
        let(:initiative) { create :initiative, :discarded, organization: organization }

        it { is_expected.to eq false }

        context "when authorizations are not required" do
          before do
            allow(Decidim::Initiatives)
              .to receive(:do_not_require_authorization)
              .and_return(true)
          end

          it { is_expected.to eq true }
        end

        context "when user is authorized" do
          before do
            create :authorization, :granted, user: user
          end

          it { is_expected.to eq true }
        end

        context "when user belongs to a verified user group" do
          before do
            create :user_group, :verified, users: [user], organization: user.organization
          end

          it { is_expected.to eq true }
        end
      end
    end
  end

  context "when voting an initiative" do
    let(:action) do
      { scope: :public, action: :vote, subject: :initiative }
    end
    let(:initiative) { create :initiative, organization: organization }
    let(:context) do
      { initiative: initiative }
    end
    let(:votes_enabled?) { true }

    before do
      allow(initiative).to receive(:votes_enabled?).and_return(votes_enabled?)
    end

    context "when initiative has votes disabled" do
      let(:votes_enabled?) { false }

      it { is_expected.to eq false }
    end

    context "when user belongs to another organization" do
      let(:user) { create :user }

      it { is_expected.to eq false }
    end

    context "when user has already voted the initiative" do
      before do
        create :initiative_user_vote, initiative: initiative, author: user
      end

      it { is_expected.to eq false }
    end

    context "when user has verified user groups" do
      before do
        create :user_group, :verified, users: [user], organization: user.organization
      end

      it { is_expected.to eq true }
    end
  end

  context "when unvoting an initiative" do
    let(:action) do
      { scope: :public, action: :unvote, subject: :initiative }
    end
    let(:initiative) { create :initiative, organization: organization }
    let(:context) do
      { initiative: initiative }
    end
    let(:votes_enabled?) { true }

    before do
      allow(initiative).to receive(:votes_enabled?).and_return(votes_enabled?)
    end

    context "when initiative has votes disabled" do
      let(:votes_enabled?) { false }

      it { is_expected.to eq false }
    end

    context "when user belongs to another organization" do
      let(:user) { create :user }

      it { is_expected.to eq false }
    end

    context "when user has not voted the initiative" do
      it { is_expected.to eq false }
    end

    context "when user has verified user groups" do
      before do
        create :user_group, :verified, users: [user], organization: user.organization
        create :initiative_user_vote, initiative: initiative, author: user
      end

      it { is_expected.to eq true }
    end
  end
end
