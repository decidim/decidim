# frozen_string_literal: true

require "spec_helper"

describe Decidim::ParticipatoryProcesses::Permissions do
  subject { described_class.new(user, permission_action, context).permissions.allowed? }

  let(:user) { create :user, :admin, organization: organization }
  let(:organization) { create :organization }
  let(:process) { create :participatory_process, organization: organization }
  let(:context) { {} }
  let(:permission_action) { Decidim::PermissionAction.new(action) }
  let(:process_admin) { create :process_admin, participatory_process: process }
  let(:process_collaborator) { create :process_collaborator, participatory_process: process }
  let(:process_moderator) { create :process_moderator, participatory_process: process }

  shared_examples "access for role" do |access|
    if access
      it { is_expected.to eq true }
    else
      it_behaves_like "permission is not set"
    end
  end

  shared_examples "access for roles" do |access|
    context "when user is org admin" do
      it_behaves_like "access for role", access[:org_admin]
    end

    context "when user is a space admin" do
      let(:user) { process_admin }

      it_behaves_like "access for role", access[:admin]
    end

    context "when user is a space collaborator" do
      let(:user) { process_collaborator }

      it_behaves_like "access for role", access[:collaborator]
    end

    context "when user is a space moderator" do
      let(:user) { process_moderator }

      it_behaves_like "access for role", access[:moderator]
    end
  end

  context "when the action is for the public part" do
    let(:action) do
      { scope: :public, action: :read, subject: :dummy_resource }
    end

    it { is_expected.to eq true }
  end

  context "when the user is not an admin but has no manageable processes" do
    let(:user) { create :user }
    let(:action) do
      { scope: :admin, action: :read, subject: :dummy_resource }
    end

    it_behaves_like "permission is not set"
  end

  context "when no user is given" do
    let(:user) { nil }
    let(:action) do
      { scope: :admin, action: :read, subject: :dummy_resource }
    end

    it_behaves_like "permission is not set"
  end

  context "when the scope is not public" do
    let(:action) do
      { scope: :foo, action: :read, subject: :dummy_resource }
    end

    it_behaves_like "permission is not set"
  end

  context "when accessing the space area" do
    let(:action) do
      { scope: :admin, action: :enter, subject: :space_area }
    end

    it_behaves_like "access for roles", org_admin: true, admin: true, collaborator: true, moderator: true
  end

  context "when reading the admin dashboard" do
    let(:action) do
      { scope: :admin, action: :read, subject: :admin_dashboard }
    end

    it_behaves_like "access for roles", org_admin: true, admin: true, collaborator: true, moderator: true
  end

  context "when acting on process groups" do
    let(:action) do
      { scope: :admin, action: :any_action_is_accepted, subject: :process_group }
    end

    it_behaves_like "access for roles", org_admin: true,badmin: false, collaborator: false, moderator: false
  end

  context "when acting on component data" do
    let(:action) do
      { scope: :admin, action: :any_action_is_accepted, subject: :component_data }
    end
    let(:context) { { current_participatory_space: process } }

    it_behaves_like "access for roles", org_admin: true, admin: true, collaborator: false, moderator: false
  end

  context "when reading the processes list" do
    let(:action) do
      { scope: :admin, action: :read, subject: :process_list }
    end

    it_behaves_like "access for roles", org_admin: true, admin: true, collaborator: true, moderator: true
  end

  context "when reading a process" do
    let(:action) do
      { scope: :admin, action: :read, subject: :process }
    end

    it_behaves_like "access for roles", org_admin: true, admin: true, collaborator: true, moderator: true
  end

  context "when reading a participatory_space" do
    let(:action) do
      { scope: :admin, action: :read, subject: :participatory_space }
    end

    it_behaves_like "access for roles", org_admin: true, admin: true, collaborator: true, moderator: true
  end

  context "when creating a process" do
    let(:action) do
      { scope: :admin, action: :create, subject: :process }
    end

    it_behaves_like "access for roles", org_admin: true, admin: false, collaborator: false, moderator: false
  end

  context "when destroying a process" do
    let(:action) do
      { scope: :admin, action: :destroy, subject: :process }
    end

    it_behaves_like "access for roles", org_admin: true, admin: false, collaborator: false, moderator: false
  end

  context "with a process" do
    let(:context) { { process: process } }

    context "when moderating a resource" do
      let(:action) do
        { scope: :admin, action: :foo, subject: :moderation }
      end

      it_behaves_like "access for roles", org_admin: true, admin: true, collaborator: false, moderator: true
    end

    context "when user is a collaborator" do
      let(:user) { process_collaborator }

      context "when action is :read" do
        let(:action) do
          { scope: :admin, action: :read, subject: :dummy }
        end

        it { is_expected.to eq true }
      end

      context "when action is :preview" do
        let(:action) do
          { scope: :admin, action: :preview, subject: :dummy }
        end

        it { is_expected.to eq true }
      end

      context "when action is a random one" do
        let(:action) do
          { scope: :admin, action: :foo, subject: :dummy }
        end

        it_behaves_like "permission is not set"
      end
    end

    context "when user is a process admin" do
      let(:user) { process_admin }

      context "when creating a process" do
        let(:action) do
          { scope: :admin, action: :create, subject: :process }
        end

        it_behaves_like "permission is not set"
      end

      context "when destroying a process" do
        let(:action) do
          { scope: :admin, action: :destroy, subject: :process }
        end

        it_behaves_like "permission is not set"
      end

      shared_examples "allows any action on subject" do |action_subject|
        context "when action subject is #{action_subject}" do
          let(:action) do
            { scope: :admin, action: :foo, subject: action_subject }
          end

          it { is_expected.to eq true }
        end
      end

      it_behaves_like "allows any action on subject", :attachment
      it_behaves_like "allows any action on subject", :attachment_collection
      it_behaves_like "allows any action on subject", :category
      it_behaves_like "allows any action on subject", :component
      it_behaves_like "allows any action on subject", :moderation
      it_behaves_like "allows any action on subject", :process
      it_behaves_like "allows any action on subject", :process_step
      it_behaves_like "allows any action on subject", :process_user_role
    end
  end
end
