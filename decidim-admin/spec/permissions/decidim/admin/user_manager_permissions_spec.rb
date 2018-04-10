# frozen_string_literal: true

require "spec_helper"

describe Decidim::Admin::UserManagerPermissions do
  subject { described_class.new(user, permission_action, context).permissions.allowed? }

  let(:user) { build :user, :user_manager }
  let(:context) { {} }
  let(:permission_action) { Decidim::PermissionAction.new(action) }
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

    it { is_expected.to eq true }
  end

  describe "managed users" do
    let(:action_subject) { :managed_user }
    let(:organization) { user.organization }
    let(:context) { { organization: organization } }

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

        it { is_expected.to eq true }
      end
    end

    context "when any other action" do
      it { is_expected.to eq true }
    end
  end

  describe "users" do
    let(:action_subject) { :user }
    let(:subject_user) { build :user }
    let(:context) { { user: subject_user } }

    context "when destroying" do
      let(:action_name) { :destroy }

      context "when destroying another user" do
        it { is_expected.to eq true }
      end

      context "when destroying itself" do
        let(:subject_user) { user }

        it_behaves_like "permission is not set"
      end
    end

    context "when impersonating" do
      let(:action_name) { :impersonate }

      before do
        allow(Decidim::ImpersonationLog)
          .to receive(:active)
          .and_return(logs)
      end

      context "when subject user is not managed" do
        let(:logs) { [] }

        it_behaves_like "permission is not set"
      end

      context "when subject user is managed" do
        let(:subject_user) { build :user, :managed }

        context "when there are active impersonation logs" do
          let(:logs) { [:foo] }

          it_behaves_like "permission is not set"
        end

        context "when there are no active impersonation logs" do
          let(:logs) { [] }

          it { is_expected.to eq true }
        end
      end
    end

    context "when any other action" do
      it { is_expected.to eq true }
    end
  end
end
