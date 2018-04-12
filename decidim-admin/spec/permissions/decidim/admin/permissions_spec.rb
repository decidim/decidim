# frozen_string_literal: true

require "spec_helper"

describe Decidim::Admin::Permissions do
  subject { described_class.new(user, permission_action, context).permissions.allowed? }

  let(:user) { build :user, :admin }
  let(:context) { {} }
  let(:permission_action) { Decidim::PermissionAction.new(action) }
  let(:space_permissions) { instance_double(Decidim::ParticipatoryProcesses::Permissions, allowed?: space_allows) }
  let(:registrations_enabled) { true }
  let(:action) do
    { scope: :admin, action: action_name, subject: action_subject }
  end
  let(:action_name) { :foo }
  let(:action_subject) { :bar }

  context "when scope is not admin" do
    let(:action) do
      { scope: :public, action: :foo, subject: :bar }
    end

    context "when reading the admin dashboard" do
      let(:action) do
        { scope: :public, action: :read, subject: :admin_dashboard }
      end

      it { is_expected.to eq true }
    end

    it_behaves_like "permission is not set"
  end

  context "when user is not present" do
    let(:user) { nil }

    it { is_expected.to eq false }
  end

  context "when user is a user manager" do
    let(:user) { build :user, :user_manager }

    it_behaves_like "delegates permissions to", Decidim::Admin::UserManagerPermissions
  end

  context "when action is not registered" do
    it_behaves_like "permission is not set"
  end

  context "when reading the admin dashboard" do
    let(:action_name) { :read }
    let(:action_subject) { :admin_dashboard }

    it { is_expected.to eq true }
  end

  describe "admin logs" do
    let(:action_subject) { :admin_log }

    it_behaves_like "permission is not set"

    context "when reading" do
      let(:action_name) { :read }

      it { is_expected.to eq true }
    end
  end

  describe "static pages" do
    let(:action_subject) { :static_page }
    let(:page) { build(:static_page, :default) }
    let(:context) { { static_page: page } }

    context "when updating" do
      let(:action_name) { :update }

      it { is_expected.to eq true }

      context "when page is not present" do
        let(:page) { nil }

        it_behaves_like "permission is not set"
      end
    end

    context "when updating the slug" do
      let(:action_name) { :update_slug }

      context "when page is not present" do
        let(:page) { nil }

        it_behaves_like "permission is not set"
      end

      context "when page is default" do
        it_behaves_like "permission is not set"
      end

      context "when page is not default" do
        let(:page) { build :static_page }

        it { is_expected.to eq true }
      end
    end

    context "when any other action" do
      it { is_expected.to eq true }
    end
  end

  describe "organization" do
    let(:action_subject) { :organization }
    let(:organization) { user.organization }
    let(:context) { { organization: organization } }

    context "when updating" do
      let(:action_name) { :update }

      context "when user belongs to organization" do
        it { is_expected.to eq true }
      end

      context "when user does not belong to organization" do
        let(:organization) { build :organization }

        it_behaves_like "permission is not set"
      end
    end

    context "when any other action" do
      it_behaves_like "permission is not set"
    end
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

        it { is_expected.to eq false }
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

  shared_examples "can perform any action for" do |action_subject_name|
    let(:action_subject) { action_subject_name }

    it { is_expected.to eq true }
  end

  it_behaves_like "can perform any action for", :category
  it_behaves_like "can perform any action for", :component
  it_behaves_like "can perform any action for", :admin_user
  it_behaves_like "can perform any action for", :attachment
  it_behaves_like "can perform any action for", :attachment_collection
  it_behaves_like "can perform any action for", :scope
  it_behaves_like "can perform any action for", :scope_type
  it_behaves_like "can perform any action for", :area
  it_behaves_like "can perform any action for", :area_type
  it_behaves_like "can perform any action for", :newsletter
  it_behaves_like "can perform any action for", :oauth_application
  it_behaves_like "can perform any action for", :user_group
  it_behaves_like "can perform any action for", :officialization
  it_behaves_like "can perform any action for", :authorization
  it_behaves_like "can perform any action for", :authorization_workflow
end
