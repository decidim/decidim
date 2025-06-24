# frozen_string_literal: true

require "spec_helper"

describe Decidim::Admin::Permissions do
  subject { described_class.new(user, permission_action, context).permissions.allowed? }

  let(:user) { build(:user, :admin, organization:) }
  let(:organization) { build(:organization) }
  let(:context) { {} }
  let(:permission_action) { Decidim::PermissionAction.new(**action) }
  let(:taxonomy) { create(:taxonomy, :with_parent, organization:) }
  let(:registrations_enabled) { true }
  let(:action) do
    { scope: :admin, action: action_name, subject: action_subject }
  end
  let(:action_name) { :foo }
  let(:action_subject) { :bar }

  shared_examples "needs to accept Terms of Service for" do |action_subject_name, action_name|
    let(:action_subject) { action_subject_name }
    let(:action_name) { action_name }

    context "when admin has accepted Terms of Service" do
      let(:user) { build(:user, :admin, admin_terms_accepted_at: Time.current, organization:) }

      it { is_expected.to be true }
    end

    context "when admin has not accepted Terms of Service" do
      let(:user) { build(:user, :admin, admin_terms_accepted_at: nil, organization:) }

      it_behaves_like "permission is not set"
    end
  end

  context "when scope is not admin" do
    let(:action) do
      { scope: :public, action: :foo, subject: :bar }
    end

    context "when reading the admin dashboard" do
      let(:action) do
        { scope: :public, action: :read, subject: :admin_dashboard }
      end

      it { is_expected.to be true }

      context "when user is a user manager" do
        let(:user) { build(:user, :user_manager) }

        it { is_expected.to be true }
      end
    end

    it_behaves_like "permission is not set"
  end

  context "when user is not present" do
    let(:user) { nil }

    it { is_expected.to be false }
  end

  context "when user is a user manager" do
    let(:user) { build(:user, :user_manager) }

    it_behaves_like "delegates permissions to", Decidim::Admin::UserManagerPermissions

    context "when entering a space area with space admin role" do
      let(:action) do
        { scope: :admin, action: :enter, subject: :space_area }
      end
      let(:participatory_process) { create(:participatory_process, organization: user.organization) }

      before do
        Decidim::ParticipatoryProcessUserRole.create(user:, participatory_process:, role: :admin)
      end

      it "allows users to enter the space area" do
        expect { subject }.to raise_error(Decidim::PermissionAction::PermissionNotSetError)
      end
    end
  end

  context "when action is not registered" do
    it_behaves_like "permission is not set"
  end

  context "when reading the admin dashboard" do
    let(:action_name) { :read }
    let(:action_subject) { :admin_dashboard }

    it { is_expected.to be true }
  end

  describe "admin logs" do
    let(:action_subject) { :admin_log }

    it_behaves_like "permission is not set"

    context "when reading" do
      let(:action_name) { :read }

      it { is_expected.to be true }
    end
  end

  describe "user statistics" do
    let(:action_subject) { :users_statistics }

    it_behaves_like "permission is not set"

    context "when reading" do
      let(:action_name) { :read }

      it { is_expected.to be true }
    end
  end

  describe "editor image upload" do
    let(:action_subject) { :editor_image }
    let(:action_name) { :create }

    it { is_expected.to be true }
  end

  describe "metrics" do
    let(:action_subject) { :metrics }

    it_behaves_like "permission is not set"

    context "when reading" do
      let(:action_name) { :read }

      it { is_expected.to be true }
    end
  end

  describe "static pages" do
    let(:action_subject) { :static_page }
    let(:page) { build(:static_page, :default) }
    let(:context) { { static_page: page } }

    context "when updating" do
      let(:action_name) { :update }

      it { is_expected.to be true }

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
        let(:page) { build(:static_page) }

        it { is_expected.to be true }
      end
    end

    context "when any other action" do
      it { is_expected.to be true }
    end
  end

  describe "global moderation" do
    it_behaves_like "needs to accept Terms of Service for", :global_moderation, :read
  end

  describe "share tokens" do
    let(:action_subject) { :share_token }

    context "when any action" do
      it { is_expected.to be true }
    end
  end

  describe "organization" do
    let(:action_subject) { :organization }
    let(:context) { { organization: } }

    context "when updating" do
      let(:action_name) { :update }

      context "when user belongs to organization" do
        it { is_expected.to be true }
      end

      context "when user does not belong to organization" do
        let(:user) { build(:user, :admin) }

        it_behaves_like "permission is not set"
      end
    end

    context "when any other action" do
      it_behaves_like "permission is not set"
    end
  end

  describe "taxonomies" do
    let(:action_subject) { :taxonomy }

    context "when any action" do
      it { is_expected.to be true }
    end

    context "when destroying is not allowed" do
      let(:context) { { taxonomy: } }
      let(:action_name) { :destroy }

      before do
        allow(taxonomy).to receive(:removable?).and_return(false)
      end

      it { is_expected.to be false }
    end
  end

  describe "taxonomy filters" do
    let(:action_subject) { :taxonomy_filter }

    context "when any action" do
      it { is_expected.to be true }
    end
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

        it { is_expected.to be false }
      end

      context "when organization available authorizations are not empty" do
        let(:authorizations) { [:foo] }

        it_behaves_like "needs to accept Terms of Service for", :managed_user, :create

        it { is_expected.to be true }
      end
    end

    context "when any other action" do
      it { is_expected.to be true }
    end
  end

  describe "users" do
    let(:action_subject) { :user }
    let(:subject_user) { build(:user) }
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
        let(:subject_user) { build(:user, :managed, organization:) }

        context "when there are active impersonation logs" do
          before do
            create(:impersonation_log, user: subject_user, admin: user)
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
      let(:organization) { build(:organization, available_authorizations: ["dummy_authorization_handler"]) }

      context "when organization has no available authorizations" do
        let(:organization) { build(:organization, available_authorizations: []) }

        it_behaves_like "permission is not set"
      end

      context "when subject user is admin" do
        let(:subject_user) { build(:user, :admin, organization:) }

        it_behaves_like "permission is not set"
      end

      context "when subject user has some roles" do
        let(:subject_user) { build(:user, roles: ["my_role"]) }

        it_behaves_like "permission is not set"
      end

      context "when there are active impersonation logs" do
        let(:subject_user) { build(:user, organization:) }

        before do
          create(:impersonation_log, user: subject_user, admin: user)
        end

        it_behaves_like "permission is not set"
      end

      context "when there are no active impersonation logs" do
        it { is_expected.to be true }
      end
    end

    context "when show their email" do
      let(:action_name) { :show_email }

      it { is_expected.to be true }

      context "when user is not an admin" do
        let(:user) { build(:user, organization:) }

        it_behaves_like "permission is not set"
      end
    end

    context "when any other action" do
      it { is_expected.to be true }
    end
  end

  describe "admins" do
    let(:action_subject) { :admin_user }

    context "when trying to delete admin rights from self" do
      let(:action_name) { :destroy }
      let(:context) { { user: } }

      it_behaves_like "permission is not set"
    end

    context "when trying to block self" do
      let(:action_name) { :block }
      let(:context) { { user: } }

      it_behaves_like "permission is not set"
    end
  end

  describe "soft delete" do
    let(:action_subject) { :resource }
    let(:action_name) { :soft_delete }
    let(:context) { { trashable_deleted_resource: resource } }

    context "when resource exists and is not trashed" do
      let(:resource) { instance_double(Decidim::Dev::DummyResource, deleted?: false) }

      it { is_expected.to be true }
    end

    context "when resource exists and is trashed" do
      let(:resource) { instance_double(Decidim::Dev::DummyResource, deleted?: true) }

      it { is_expected.to be false }
    end
  end

  describe "restore" do
    let(:action_subject) { :resource }
    let(:action_name) { :restore }
    let(:context) { { trashable_deleted_resource: resource } }

    context "when resource exists and is trashed" do
      let(:resource) { instance_double(Decidim::Dev::DummyResource, deleted?: true) }

      it { is_expected.to be true }
    end

    context "when resource exists and is not trashed" do
      let(:resource) { instance_double(Decidim::Dev::DummyResource, deleted?: false) }

      it { is_expected.to be false }
    end
  end

  describe "manage trash" do
    let(:action_subject) { :resource }
    let(:action_name) { :manage_trash }
    let(:context) { { trashable_deleted_resource: resource } }

    context "when any resource" do
      let(:resource) { instance_double(Decidim::Dev::DummyResource) }

      it { is_expected.to be true }
    end
  end

  shared_examples "can perform any action for" do |action_subject_name|
    let(:action_subject) { action_subject_name }

    it { is_expected.to be true }
  end

  it_behaves_like "can perform any action for", :component
  it_behaves_like "can perform any action for", :admin_user
  it_behaves_like "can perform any action for", :attachment
  it_behaves_like "can perform any action for", :attachment_collection
  it_behaves_like "can perform any action for", :scope
  it_behaves_like "can perform any action for", :scope_type
  it_behaves_like "can perform any action for", :area
  it_behaves_like "can perform any action for", :area_type
  it_behaves_like "can perform any action for", :newsletter
  it_behaves_like "can perform any action for", :user_group
  it_behaves_like "can perform any action for", :officialization
  it_behaves_like "can perform any action for", :moderate_users
  it_behaves_like "can perform any action for", :authorization
  it_behaves_like "can perform any action for", :authorization_workflow
end
