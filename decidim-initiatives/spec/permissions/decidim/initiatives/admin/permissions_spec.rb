# frozen_string_literal: true

require "spec_helper"

describe Decidim::Initiatives::Admin::Permissions do
  subject { described_class.new(user, permission_action, context).permissions.allowed? }

  let(:user) { create :user, organization: }
  let(:organization) { create :organization }
  let(:initiative) { create :initiative, organization: }
  let(:context) { { initiative: } }
  let(:permission_action) { Decidim::PermissionAction.new(**action) }
  let(:initiatives_settings) { create :initiatives_settings, organization: }
  let(:action) do
    { scope: :admin, action: action_name, subject: action_subject }
  end

  shared_examples "checks initiative state" do |name, valid_trait, invalid_trait|
    let(:action_name) { name }

    context "when initiative is #{valid_trait}" do
      let(:initiative) { create :initiative, valid_trait, organization: }

      it { is_expected.to be true }
    end

    context "when initiative is not #{valid_trait}" do
      let(:initiative) { create :initiative, invalid_trait, organization: }

      it { is_expected.to be false }
    end
  end

  shared_examples "initiative committee action" do
    let(:action_subject) { :initiative_committee_member }

    context "when indexing" do
      let(:action_name) { :index }

      it { is_expected.to be true }
    end

    context "when approving" do
      let(:action_name) { :approve }
      let(:context) { { initiative:, request: } }

      context "when request is not accepted yet" do
        let(:request) { create :initiatives_committee_member, :requested, initiative: }

        it { is_expected.to be true }
      end

      context "when request is already accepted" do
        let(:request) { create :initiatives_committee_member, :accepted, initiative: }

        it { is_expected.to be false }
      end
    end

    context "when revoking" do
      let(:action_name) { :revoke }
      let(:context) { { initiative:, request: } }

      context "when request is not revoked yet" do
        let(:request) { create :initiatives_committee_member, :accepted, initiative: }

        it { is_expected.to be true }
      end

      context "when request is already revoked" do
        let(:request) { create :initiatives_committee_member, :rejected, initiative: }

        it { is_expected.to be false }
      end
    end

    context "when any other condition" do
      let(:action_name) { :foo }

      it_behaves_like "permission is not set"
    end
  end

  context "when the action is not for the admin part" do
    let(:action) do
      { scope: :public, action: :foo, subject: :initiative }
    end

    it_behaves_like "permission is not set"
  end

  context "when user is not given" do
    let(:user) { nil }
    let(:action) do
      { scope: :admin, action: :foo, subject: :initiative }
    end

    it_behaves_like "permission is not set"
  end

  context "when checking access to space area" do
    let(:action) do
      { scope: :admin, action: :enter, subject: :space_area }
    end
    let(:context) { { space_name: :initiatives } }

    context "when user created an initiative" do
      let(:initiative) { create :initiative, author: user, organization: }

      before { initiative }

      it { is_expected.to be true }
    end

    context "when user promoted an initiative" do
      before do
        create :initiatives_committee_member, initiative:, user:
      end

      it { is_expected.to be true }
    end

    context "when user is admin" do
      let(:user) { create :user, :admin, organization: }

      it { is_expected.to be true }
    end

    context "when space name is not set" do
      let(:context) { {} }

      it_behaves_like "permission is not set"
    end
  end

  context "when user is a member of the initiative" do
    before do
      create :initiatives_committee_member, initiative:, user:
    end

    it_behaves_like "initiative committee action"

    context "when managing initiatives" do
      let(:action_subject) { :initiative }

      context "when reading" do
        let(:action_name) { :read }

        before do
          allow(Decidim::Initiatives).to receive(:print_enabled).and_return(print_enabled)
        end

        context "when print is disabled" do
          let(:print_enabled) { false }

          it { is_expected.to be false }
        end

        context "when print is enabled" do
          let(:print_enabled) { true }

          it { is_expected.to be true }
        end
      end

      context "when updating" do
        let(:action_name) { :update }

        context "when initiative is created" do
          let(:initiative) { create :initiative, :created, organization: }

          it { is_expected.to be true }
        end

        context "when initiative is not created" do
          it { is_expected.to be false }
        end
      end

      context "when sending to technical validation" do
        let(:action_name) { :send_to_technical_validation }

        context "when initiative is created" do
          let(:initiative) { create :initiative, :created, organization: }

          context "when initiative is authored by a user group" do
            let(:user_group) { create :user_group, organization: user.organization, users: [user] }

            before do
              initiative.update(decidim_user_group_id: user_group.id)
            end

            it { is_expected.to be true }
          end

          context "when initiative has enough approved members" do
            before do
              allow(initiative).to receive(:enough_committee_members?).and_return(true)
            end

            it { is_expected.to be true }
          end

          context "when initiative has not enough approved members" do
            before do
              allow(initiative).to receive(:enough_committee_members?).and_return(false)
            end

            it { is_expected.to be false }
          end
        end

        context "when initiative is discarded" do
          let(:initiative) { create :initiative, :discarded, organization: }

          it { is_expected.to be true }
        end

        context "when initiative is not created or discarded" do
          it { is_expected.to be false }
        end
      end

      context "when editing" do
        let(:action_name) { :edit }

        it { is_expected.to be true }
      end

      context "when previewing" do
        let(:action_name) { :preview }

        it { is_expected.to be true }
      end

      context "when managing memberships" do
        let(:action_name) { :manage_membership }

        it { is_expected.to be true }
      end

      context "when reading a initiatives settings" do
        let(:action_subject) { :initiatives_settings }
        let(:action_name) { :update }

        it { is_expected.to be false }
      end

      context "when any other action" do
        let(:action_name) { :foo }

        it { is_expected.to be false }
      end
    end

    context "when managing attachments" do
      let(:action_subject) { :attachment }

      shared_examples "attached to an initiative" do |name|
        context "when action is #{name}" do
          let(:action_name) { name }
          let(:context) { { initiative:, attachment: } }

          context "when attached to an initiative" do
            let(:attachment) { create :attachment, attached_to: initiative }

            it { is_expected.to be true }
          end

          context "when attached to something else" do
            let(:attachment) { create :attachment }

            it { is_expected.to be false }
          end
        end
      end

      context "when reading" do
        let(:action_name) { :read }

        it { is_expected.to be true }
      end

      context "when creating" do
        let(:action_name) { :create }

        it { is_expected.to be true }
      end

      it_behaves_like "attached to an initiative", :update
      it_behaves_like "attached to an initiative", :destroy
    end
  end

  context "when user is admin" do
    let(:user) { create :user, :admin, organization: }

    it_behaves_like "initiative committee action"

    context "when managing attachments" do
      let(:action_subject) { :attachment }
      let(:action_name) { :foo }

      it { is_expected.to be true }
    end

    context "when managing initiative types" do
      let(:action_subject) { :initiative_type }

      context "when destroying" do
        let(:action_name) { :destroy }
        let(:initiative_type) { create :initiatives_type }
        let(:organization) { initiative_type.organization }
        let(:context) { { initiative_type: } }

        before do
          allow(initiative_type).to receive(:scopes).and_return(scopes)
        end

        context "when its scopes are empty" do
          let(:scopes) do
            [
              double(initiatives: [])
            ]
          end

          it { is_expected.to be true }
        end

        context "when its scopes are not empty" do
          let(:scopes) do
            [
              double(initiatives: [1, 2, 3])
            ]
          end

          it { is_expected.to be false }
        end
      end

      context "when any random action" do
        let(:action_name) { :foo }

        it { is_expected.to be true }
      end
    end

    context "when managing initiative type scopes" do
      let(:action_subject) { :initiative_type_scope }

      context "when destroying" do
        let(:action_name) { :destroy }
        let(:scope) { create :initiatives_type_scope }
        let(:context) { { initiative_type_scope: scope } }

        before do
          allow(scope).to receive(:initiatives).and_return(initiatives)
        end

        context "when it has no initiatives" do
          let(:initiatives) do
            []
          end

          it { is_expected.to be true }
        end

        context "when it has some initiatives" do
          let(:initiatives) do
            [1, 2, 3]
          end

          it { is_expected.to be false }
        end
      end

      context "when any random action" do
        let(:action_name) { :foo }

        it { is_expected.to be true }
      end
    end

    context "when managing initiatives" do
      let(:action_subject) { :initiative }

      context "when reading" do
        let(:action_name) { :read }

        before do
          allow(Decidim::Initiatives).to receive(:print_enabled).and_return(print_enabled)
        end

        context "when print is disabled" do
          let(:print_enabled) { false }

          it { is_expected.to be false }
        end

        context "when print is enabled" do
          let(:print_enabled) { true }

          it { is_expected.to be true }
        end
      end

      it_behaves_like "checks initiative state", :publish, :validating, :published
      it_behaves_like "checks initiative state", :unpublish, :published, :validating
      it_behaves_like "checks initiative state", :discard, :validating, :published
      it_behaves_like "checks initiative state", :export_votes, :offline, :online
      it_behaves_like "checks initiative state", :export_pdf_signatures, :published, :validating

      context "when accepting the initiative" do
        let(:action_name) { :accept }
        let(:initiative) { create :initiative, organization:, signature_end_date: 2.days.ago }
        let(:goal_reached) { true }

        before do
          allow(initiative).to receive(:supports_goal_reached?).and_return(goal_reached)
        end

        it { is_expected.to be true }

        context "when the initiative is not published" do
          let(:initiative) { create :initiative, :validating, organization: }

          it { is_expected.to be false }
        end

        context "when the initiative signature time is not finished" do
          let(:initiative) { create :initiative, signature_end_date: 2.days.from_now, organization: }

          it { is_expected.to be false }
        end

        context "when the initiative percentage is not complete" do
          let(:goal_reached) { false }

          it { is_expected.to be false }
        end
      end

      context "when rejecting the initiative" do
        let(:action_name) { :reject }
        let(:initiative) { create :initiative, organization:, signature_end_date: 2.days.ago }
        let(:goal_reached) { false }

        before do
          allow(initiative).to receive(:supports_goal_reached?).and_return(goal_reached)
        end

        it { is_expected.to be true }

        context "when the initiative is not published" do
          let(:initiative) { create :initiative, :validating, organization: }

          it { is_expected.to be false }
        end

        context "when the initiative signature time is not finished" do
          let(:initiative) { create :initiative, signature_end_date: 2.days.from_now, organization: }

          it { is_expected.to be false }
        end

        context "when the initiative percentage is complete" do
          let(:goal_reached) { true }

          it { is_expected.to be false }
        end
      end
    end

    context "when reading a initiatives settings" do
      let(:action_subject) { :initiatives_settings }
      let(:action_name) { :update }

      it { is_expected.to be true }
    end
  end

  context "when any other condition" do
    let(:action) do
      { scope: :admin, action: :foo, subject: :bar }
    end

    it_behaves_like "permission is not set"
  end
end
