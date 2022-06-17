# frozen_string_literal: true

require "spec_helper"

describe Decidim::Initiatives::Permissions do
  subject { described_class.new(user, permission_action, context).permissions.allowed? }

  let(:user) { create :user, organization: }
  let(:organization) { create :organization }
  let(:initiative) { create(:initiative, organization:) }
  let(:context) { {} }
  let(:permission_action) { Decidim::PermissionAction.new(**action) }

  shared_examples "votes permissions" do
    let(:organization) { create(:organization, available_authorizations: authorizations) }
    let(:authorizations) { %w(dummy_authorization_handler another_dummy_authorization_handler) }
    let(:initiative) { create(:initiative, organization:) }
    let(:context) do
      { initiative: }
    end
    let(:votes_enabled?) { true }

    before do
      allow(initiative).to receive(:votes_enabled?).and_return(votes_enabled?)
    end

    context "when initiative has votes disabled" do
      let(:votes_enabled?) { false }

      it { is_expected.to be false }
    end

    context "when user belongs to another organization" do
      let(:user) { create :user }

      it { is_expected.to be false }
    end

    context "when user has already voted the initiative" do
      before do
        create(:initiative_user_vote, initiative:, author: user)
      end

      it { is_expected.to be false }
    end

    context "when user has verified user groups" do
      before do
        create :user_group, :verified, users: [user], organization: user.organization
      end

      it { is_expected.to be true }
    end

    context "when the initiative type has permissions to vote" do
      before do
        initiative.type.create_resource_permission(
          permissions: {
            "vote" => {
              "authorization_handlers" => {
                "dummy_authorization_handler" => { "options" => {} },
                "another_dummy_authorization_handler" => { "options" => {} }
              }
            }
          }
        )
      end

      context "when user is not verified" do
        it { is_expected.to be false }
      end

      context "when user is not fully verified" do
        before do
          create(:authorization, name: "dummy_authorization_handler", user:, granted_at: 2.seconds.ago)
        end

        it { is_expected.to be false }
      end

      context "when user is fully verified" do
        before do
          create(:authorization, name: "dummy_authorization_handler", user:, granted_at: 2.seconds.ago)
          create(:authorization, name: "another_dummy_authorization_handler", user:, granted_at: 2.seconds.ago)
        end

        it { is_expected.to be true }
      end
    end
  end

  context "when the action is for the admin part" do
    let(:action) do
      { scope: :admin, action: :foo, subject: :initiative }
    end

    it_behaves_like "delegates permissions to", Decidim::Initiatives::Admin::Permissions
  end

  context "when reading an initiative" do
    let(:initiative) { create(:initiative, :discarded, organization:) }
    let(:action) do
      { scope: :public, action: :read, subject: :initiative }
    end
    let(:context) do
      { initiative: }
    end

    context "when initiative is published" do
      let(:initiative) { create(:initiative, :published, organization:) }

      it { is_expected.to be true }
    end

    context "when initiative is rejected" do
      let(:initiative) { create(:initiative, :rejected, organization:) }

      it { is_expected.to be true }
    end

    context "when initiative is accepted" do
      let(:initiative) { create(:initiative, :accepted, organization:) }

      it { is_expected.to be true }
    end

    context "when user is admin" do
      let(:user) { create :user, :admin, organization: }

      it { is_expected.to be true }
    end

    context "when user is author of the initiative" do
      let(:initiative) { create(:initiative, author: user, organization:) }

      it { is_expected.to be true }
    end

    context "when user is committee member of the initiative" do
      before do
        create(:initiatives_committee_member, initiative:, user:)
      end

      it { is_expected.to be true }
    end

    context "when any other condition" do
      it { is_expected.to be false }
    end
  end

  context "when listing committee members of the initiative as author" do
    let(:initiative) { create(:initiative, organization:, author: user) }
    let(:action) do
      { scope: :public, action: :index, subject: :initiative_committee_member }
    end
    let(:context) do
      { initiative: }
    end

    it { is_expected.to be true }
  end

  context "when approving committee member of the initiative as author" do
    let(:initiative) { create(:initiative, organization:, author: user) }
    let(:action) do
      { scope: :public, action: :approve, subject: :initiative_committee_member }
    end
    let(:context) do
      { initiative: }
    end

    it { is_expected.to be true }
  end

  context "when revoking committee member of the initiative as author" do
    let(:initiative) { create(:initiative, organization:, author: user) }
    let(:action) do
      { scope: :public, action: :revoke, subject: :initiative_committee_member }
    end
    let(:context) do
      { initiative: }
    end

    it { is_expected.to be true }
  end

  context "when sending initiative to technical validation as author" do
    let(:initiative) { create(:initiative, state: :created, organization:) }
    let(:action) do
      { scope: :public, action: :send_to_technical_validation, subject: :initiative }
    end
    let(:context) do
      { initiative: }
    end

    it { is_expected.to be true }
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

      it { is_expected.to be false }

      context "when authorizations are not required" do
        before do
          allow(Decidim::Initiatives)
            .to receive(:do_not_require_authorization)
            .and_return(true)
        end

        it { is_expected.to be true }
      end

      context "when user is authorized" do
        before do
          create :authorization, :granted, user:
        end

        it { is_expected.to be true }
      end

      context "when user belongs to a verified user group" do
        before do
          create :user_group, :verified, users: [user], organization: user.organization
        end

        it { is_expected.to be true }
      end
    end

    context "when creation is not enabled" do
      before do
        allow(Decidim::Initiatives)
          .to receive(:creation_enabled)
          .and_return(false)
      end

      it { is_expected.to be false }
    end
  end

  context "when managing an initiative" do
    let(:action_subject) { :initiative }

    context "when editing" do
      let(:action_name) { :edit }
      let(:action) do
        { scope: :public, action: :edit, subject: :initiative }
      end
      let(:context) do
        { initiative: }
      end

      context "when initiative is not created" do
        let(:initiative) { create(:initiative, author: user, organization:) }

        it { is_expected.to be false }
      end

      context "when user is a committee member" do
        let(:initiative) { create(:initiative, :created, organization:) }

        before do
          create(:initiatives_committee_member, initiative:, user:)
        end

        it { is_expected.to be true }
      end

      context "when user is not an initiative author" do
        let(:initiative) { create(:initiative, :created, organization:) }

        it { is_expected.to be false }
      end

      context "when user is admin" do
        let(:user) { create :user, :admin, organization: }
        let(:initiative) { create(:initiative, :created, author: user, organization:) }

        it { is_expected.to be true }
      end
    end

    context "when updating" do
      let(:action_name) { :update }
      let(:action) do
        { scope: :public, action: :edit, subject: :initiative }
      end
      let(:context) do
        { initiative: }
      end

      context "when initiative is not created" do
        let(:initiative) { create(:initiative, organization:) }

        it { is_expected.to be false }
      end

      context "when user is a committee member" do
        let(:initiative) { create(:initiative, :created, organization:) }

        before do
          create(:initiatives_committee_member, user:, initiative:)
        end

        it { is_expected.to be true }
      end

      context "when user is not an initiative author" do
        let(:initiative) { create(:initiative, :created, organization:) }

        it { is_expected.to be false }
      end

      context "when user is admin" do
        let(:user) { create :user, :admin, organization: }
        let(:initiative) { create(:initiative, :created, author: user, organization:) }

        it { is_expected.to be true }
      end
    end
  end

  context "when requesting membership to an initiative" do
    let(:action) do
      { scope: :public, action: :request_membership, subject: :initiative }
    end
    let(:initiative) { create(:initiative, :discarded, organization:) }
    let(:context) do
      { initiative: }
    end

    context "when initiative is published" do
      let(:initiative) { create(:initiative, :published, organization:) }

      it { is_expected.to be false }
    end

    context "when initiative is not published" do
      context "when user is member" do
        let(:initiative) { create(:initiative, :discarded, author: user, organization:) }

        it { is_expected.to be false }
      end

      context "when user is not a member" do
        let(:initiative) { create(:initiative, :discarded, organization:) }

        it { is_expected.to be false }

        context "when authorizations are not required" do
          before do
            allow(Decidim::Initiatives)
              .to receive(:do_not_require_authorization)
              .and_return(true)
          end

          it { is_expected.to be true }
        end

        context "when user is authorized" do
          before do
            create :authorization, :granted, user:
          end

          it { is_expected.to be true }
        end

        context "when user belongs to a verified user group" do
          before do
            create :user_group, :verified, users: [user], organization: user.organization
          end

          it { is_expected.to be true }
        end

        context "when user is not connected" do
          let(:user) { nil }

          it { is_expected.to be true }
        end
      end
    end
  end

  context "when voting an initiative" do
    it_behaves_like "votes permissions" do
      let(:action) do
        { scope: :public, action: :vote, subject: :initiative }
      end
    end
  end

  context "when signing an initiative" do
    context "when initiative signature has steps" do
      it_behaves_like "votes permissions" do
        let(:action) do
          { scope: :public, action: :sign_initiative, subject: :initiative }
        end
        let(:context) do
          { initiative:, signature_has_steps: true }
        end
      end
    end

    context "when initiative signature doesn't have steps" do
      let(:organization) { create(:organization, available_authorizations: authorizations) }
      let(:authorizations) { %w(dummy_authorization_handler another_dummy_authorization_handler) }
      let(:initiative) { create(:initiative, organization:) }
      let(:votes_enabled?) { true }
      let(:action) do
        { scope: :public, action: :sign_initiative, subject: :initiative }
      end
      let(:context) do
        { initiative:, signature_has_steps: false }
      end

      before do
        allow(initiative).to receive(:votes_enabled?).and_return(votes_enabled?)
      end

      context "when user has verified user groups" do
        before do
          create :user_group, :verified, users: [user], organization: user.organization
        end

        it { is_expected.to be false }
      end

      context "when the initiative type has permissions to vote" do
        before do
          initiative.type.create_resource_permission(
            permissions: {
              "vote" => {
                "authorization_handlers" => {
                  "dummy_authorization_handler" => { "options" => {} },
                  "another_dummy_authorization_handler" => { "options" => {} }
                }
              }
            }
          )
        end

        context "when user is fully verified" do
          before do
            create(:authorization, name: "dummy_authorization_handler", user:, granted_at: 2.seconds.ago)
            create(:authorization, name: "another_dummy_authorization_handler", user:, granted_at: 2.seconds.ago)
          end

          it { is_expected.to be false }
        end
      end
    end
  end

  context "when unvoting an initiative" do
    let(:action) do
      { scope: :public, action: :unvote, subject: :initiative }
    end
    let(:initiative) { create(:initiative, organization:) }
    let(:context) do
      { initiative: }
    end
    let(:votes_enabled?) { true }
    let(:accepts_online_unvotes?) { true }

    before do
      allow(initiative).to receive(:votes_enabled?).and_return(votes_enabled?)
      allow(initiative).to receive(:accepts_online_unvotes?).and_return(accepts_online_unvotes?)
    end

    context "when initiative has votes disabled" do
      let(:votes_enabled?) { false }

      it { is_expected.to be false }
    end

    context "when initiative has unvotes disabled" do
      let(:accepts_online_unvotes?) { false }

      it { is_expected.to be false }
    end

    context "when user belongs to another organization" do
      let(:user) { create :user }

      it { is_expected.to be false }
    end

    context "when user has not voted the initiative" do
      it { is_expected.to be false }
    end

    context "when user has verified user groups" do
      before do
        create :user_group, :verified, users: [user], organization: user.organization
        create(:initiative_user_vote, initiative:, author: user)
      end

      it { is_expected.to be true }
    end
  end
end
