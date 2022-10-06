# frozen_string_literal: true

require "spec_helper"

describe Decidim::Admin::UserManagerPermissions do
  subject { described_class.new(user, permission_action, context).permissions.allowed? }

  let(:user) { build :user, :user_manager, organization: }
  let(:organization) { build :organization }
  let(:context) { {} }
  let(:permission_action) { Decidim::PermissionAction.new(**action) }
  let(:space_permissions) { instance_double(Decidim::ParticipatoryProcesses::Permissions, allowed?: space_allows) }
  let(:registrations_enabled) { true }
  let(:action) do
    { scope: :admin, action: action_name, subject: action_subject }
  end
  let(:action_name) { :foo }
  let(:action_subject) { :bar }

  context "when action is not registered" do
    it_behaves_like "permission is not set"
  end

  context "when reading the admin dashboard" do
    let(:action_name) { :read }
    let(:action_subject) { :admin_dashboard }

    it { is_expected.to be true }
  end

  describe "managed users" do
    let(:action_subject) { :managed_user }
    let(:context) { { organization: } }

    context "when creating" do
      let(:action_name) { :create }

      before do
        allow(organization)
          .to receive(:available_authorizations)
          .and_return(authorizations)
      end

      context "when organization available authorizations are empty" do
        let(:authorizations) { [] }

        it_behaves_like "permission is not set"
      end

      context "when organization available authorizations are not empty" do
        let(:authorizations) { [:foo] }

        it { is_expected.to be true }
      end
    end

    context "when any other action" do
      it { is_expected.to be true }
    end
  end

  describe "users" do
    let(:action_subject) { :user }
    let(:subject_user) { build :user }
    let(:context) { { user: subject_user } }

    context "when destroying" do
      let(:action_name) { :destroy }

      context "when destroying another user" do
        it { is_expected.to be true }
      end

      context "when destroying itself" do
        let(:subject_user) { user }

        it_behaves_like "permission is not set"
      end
    end

    context "when promoting" do
      let(:action_name) { :promote }

      context "when subject user is not managed" do
        it_behaves_like "permission is not set"
      end

      context "when subject user is managed" do
        let(:subject_user) { build :user, :managed, organization: }

        context "when there are active impersonation logs" do
          before do
            create :impersonation_log, user: subject_user, admin: user
          end

          it_behaves_like "permission is not set"
        end

        context "when there are no active impersonation logs" do
          it { is_expected.to be true }
        end
      end
    end

    context "when impersonating" do
      let(:action_name) { :impersonate }
      let(:organization) { build :organization, available_authorizations: ["dummy_authorization_handler"] }

      context "when organization has no available authorizations" do
        let(:organization) { build :organization, available_authorizations: [] }

        it_behaves_like "permission is not set"
      end

      context "when subject user is admin" do
        let(:subject_user) { build :user, :admin, organization: }

        it_behaves_like "permission is not set"
      end

      context "when subject user has some roles" do
        let(:subject_user) { build :user, roles: ["my_role"] }

        it_behaves_like "permission is not set"
      end

      context "when there are active impersonation logs" do
        let(:subject_user) { build :user, organization: }

        before do
          create :impersonation_log, user: subject_user, admin: user
        end

        it_behaves_like "permission is not set"
      end

      context "when there are no active impersonation logs" do
        it { is_expected.to be true }
      end
    end

    context "when any other action" do
      it { is_expected.to be true }
    end
  end
end
