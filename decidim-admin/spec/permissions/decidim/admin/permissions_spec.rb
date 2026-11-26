# frozen_string_literal: true

require "spec_helper"
require "decidim/conferences/test/factories"

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

  context "when accepting the admin terms of service" do
    let(:organization) { create(:organization) }
    let(:user) { create(:user, organization:) }
    let(:action_name) { :accept }
    let(:action_subject) { :admin_terms }

    context "when the user has a role in a participatory space" do
      let(:assembly) { create(:assembly, organization:) }

      before { create(:assembly_user_role, user:, assembly:) }

      it { is_expected.to be true }
    end

    context "when the only role the user has is in a trashed participatory space" do
      let(:assembly) { create(:assembly, :trashed, organization:) }

      before { create(:assembly_user_role, user:, assembly:) }

      it_behaves_like "permission is not set"
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

  describe "trash actions for participatory space roles" do
    let(:organization) { create(:organization) }
    let(:user) { create(:user, :confirmed, admin_terms_accepted_at: Time.current, organization:) }
    let(:current_component) { create(:dummy_component, participatory_space:) }
    let(:resource) { create(:dummy_resource, component: current_component).tap { |resource| resource.destroy! if trashed } }
    let(:role) { nil }
    let(:trashed) { false }
    let(:other_space_organization) { organization }
    let(:action_subject) { :dummy_resource }
    let(:context) do
      {
        current_organization: organization,
        current_component:,
        current_participatory_space: participatory_space,
        participatory_space:,
        trashable_deleted_resource: resource
      }
    end

    shared_examples "space admin trash permissions" do
      context "when the user is a space admin" do
        let(:role) { :admin }

        context "when soft deleting a resource that is not trashed" do
          let(:action_name) { :soft_delete }

          it { is_expected.to be true }
        end

        context "when soft deleting a resource that is already trashed" do
          let(:action_name) { :soft_delete }
          let(:trashed) { true }

          it { is_expected.to be false }
        end

        context "when restoring a trashed resource" do
          let(:action_name) { :restore }
          let(:trashed) { true }

          it { is_expected.to be true }
        end

        context "when restoring a resource that is not trashed" do
          let(:action_name) { :restore }

          it { is_expected.to be false }
        end

        context "when managing the trash" do
          let(:action_name) { :manage_trash }
          let(:resource) { nil }

          it { is_expected.to be true }
        end

        context "when the admin has not accepted the admin Terms of Service" do
          let(:user) { create(:user, :confirmed, admin_terms_accepted_at: nil, organization:) }
          let(:action_name) { :soft_delete }

          it_behaves_like "permission is not set"
        end

        context "when the resource belongs to another participatory space" do
          let(:other_component) { create(:dummy_component, organization:) }
          let(:resource) { create(:dummy_resource, component: other_component) }
          let(:action_name) { :soft_delete }

          it_behaves_like "permission is not set"
        end

        context "when the resource belongs to another component of the same participatory space" do
          let(:other_component) { create(:dummy_component, participatory_space:) }
          let(:resource) { create(:dummy_resource, component: other_component).tap { |resource| resource.destroy! if trashed } }

          [:soft_delete, :restore].each do |trash_action|
            context "when the action is #{trash_action}" do
              let(:action_name) { trash_action }
              let(:trashed) { trash_action == :restore }

              it_behaves_like "permission is not set"
            end
          end
        end

        context "when the current component belongs to another participatory space" do
          let(:current_component) { create(:dummy_component, organization:) }
          let(:action_name) { :manage_trash }
          let(:resource) { nil }

          it_behaves_like "permission is not set"
        end

        context "when there is no current component" do
          let(:current_component) { nil }

          [:soft_delete, :restore, :manage_trash].each do |trash_action|
            context "when the action is #{trash_action}" do
              let(:action_name) { trash_action }
              let(:action_subject) { space_subject }
              let(:resource) { participatory_space }

              before { participatory_space.destroy! if trash_action == :restore }

              it_behaves_like "permission is not set"
            end
          end
        end
      end

      [:collaborator, :evaluator, :moderator].each do |non_admin_role|
        context "when the user is a space #{non_admin_role}" do
          let(:role) { non_admin_role }

          context "when the action is soft_delete" do
            let(:action_name) { :soft_delete }

            it_behaves_like "permission is not set"
          end

          context "when the action is manage_trash" do
            let(:action_name) { :manage_trash }
            let(:resource) { nil }

            it_behaves_like "permission is not set"
          end

          context "when the action is restore" do
            let(:action_name) { :restore }
            let(:trashed) { true }

            it_behaves_like "permission is not set"
          end
        end
      end

      context "when the user is an admin of another participatory space" do
        let(:action_name) { :soft_delete }

        before do
          other_space_role
        end

        it_behaves_like "permission is not set"
      end

      context "when the user is an admin of a participatory space in another organization" do
        let(:other_space_organization) { create(:organization) }
        let(:user) { create(:user, :confirmed, admin_terms_accepted_at: Time.current, organization: other_space_organization) }

        before do
          other_space_role
        end

        [:soft_delete, :restore].each do |trash_action|
          context "when the action is #{trash_action}" do
            let(:action_name) { trash_action }
            let(:trashed) { trash_action == :restore }

            it_behaves_like "permission is not set"
          end
        end

        context "when the action is manage_trash" do
          let(:action_name) { :manage_trash }
          let(:resource) { nil }

          it_behaves_like "permission is not set"
        end
      end

      context "when there is no user" do
        let(:user) { nil }

        [:soft_delete, :restore, :manage_trash].each do |trash_action|
          context "when the action is #{trash_action}" do
            let(:action_name) { trash_action }
            let(:trashed) { trash_action == :restore }

            it { is_expected.to be false }
          end
        end
      end
    end

    context "when the space is a participatory process" do
      let(:participatory_space) { create(:participatory_process, organization:) }
      let(:space_subject) { :participatory_process }
      let(:other_space_role) do
        create(:participatory_process_user_role, user:, role: :admin,
                                                 participatory_process: create(:participatory_process, organization: other_space_organization))
      end

      before do
        create(:participatory_process_user_role, user:, participatory_process: participatory_space, role:) if role
      end

      it_behaves_like "space admin trash permissions"
    end

    context "when the space is an assembly" do
      let(:participatory_space) { create(:assembly, organization:) }
      let(:space_subject) { :assembly }
      let(:other_space_role) do
        create(:assembly_user_role, user:, role: :admin, assembly: create(:assembly, organization: other_space_organization))
      end

      before do
        create(:assembly_user_role, user:, assembly: participatory_space, role:) if role
      end

      it_behaves_like "space admin trash permissions"

      context "when the user is an admin of the parent assembly" do
        let(:parent_assembly) { create(:assembly, organization:) }
        let(:participatory_space) { create(:assembly, parent: parent_assembly, organization:) }
        let(:action_name) { :soft_delete }

        before do
          create(:assembly_user_role, user:, assembly: parent_assembly, role: :admin)
        end

        it { is_expected.to be true }
      end

      context "when the user is an admin of the grandparent assembly" do
        let(:grandparent_assembly) { create(:assembly, organization:) }
        let(:parent_assembly) { create(:assembly, parent: grandparent_assembly, organization:) }
        let(:participatory_space) { create(:assembly, parent: parent_assembly, organization:) }
        let(:action_name) { :soft_delete }

        before do
          create(:assembly_user_role, user:, assembly: grandparent_assembly, role: :admin)
          create(:assembly_user_role, user:, assembly: participatory_space, role: :collaborator)
        end

        it_behaves_like "permission is not set"
      end
    end

    context "when the space is a conference" do
      let(:participatory_space) { create(:conference, organization:) }
      let(:space_subject) { :conference }
      let(:other_space_role) do
        create(:conference_user_role, user:, role: :admin, conference: create(:conference, organization: other_space_organization))
      end

      before do
        create(:conference_user_role, user:, conference: participatory_space, role:) if role
      end

      it_behaves_like "space admin trash permissions"
    end

    context "when the user is an organization admin" do
      let(:user) { create(:user, :admin, :confirmed, organization:) }
      let(:participatory_space) { create(:participatory_process, organization:) }

      context "when soft deleting a resource that is not trashed" do
        let(:action_name) { :soft_delete }

        it { is_expected.to be true }
      end

      context "when restoring a trashed resource" do
        let(:action_name) { :restore }
        let(:trashed) { true }

        it { is_expected.to be true }
      end
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
  it_behaves_like "can perform any action for", :officialization
  it_behaves_like "can perform any action for", :moderate_users
  it_behaves_like "can perform any action for", :authorization
  it_behaves_like "can perform any action for", :authorization_workflow
end
