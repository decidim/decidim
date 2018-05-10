
# frozen_string_literal: true

require "spec_helper"

describe Decidim::Assemblies::Permissions do
  subject { described_class.new(user, permission_action, context).permissions.allowed? }

  let(:user) { create :user, :admin, organization: organization }
  let(:organization) { create :organization }
  let(:assembly) { create :assembly, organization: organization }
  let(:context) { {} }
  let(:permission_action) { Decidim::PermissionAction.new(action) }
  let(:assembly_admin) { create :assembly_admin, assembly: assembly }
  let(:assembly_collaborator) { create :assembly_collaborator, assembly: assembly }
  let(:assembly_moderator) { create :assembly_moderator, assembly: assembly }

  shared_examples "access for role" do |access|
    if access == true
      it { is_expected.to eq true }
    elsif access == :not_set
      it_behaves_like "permission is not set"
    else
      it { is_expected.to eq false }
    end
  end

  shared_examples "access for roles" do |access|
    context "when user is org admin" do
      it_behaves_like "access for role", access[:org_admin]
    end

    context "when user is a space admin" do
      let(:user) { assembly_admin }

      it_behaves_like "access for role", access[:admin]
    end

    context "when user is a space collaborator" do
      let(:user) { assembly_collaborator }

      it_behaves_like "access for role", access[:collaborator]
    end

    context "when user is a space moderator" do
      let(:user) { assembly_moderator }

      it_behaves_like "access for role", access[:moderator]
    end
  end

  context "when the action is for the public part" do
    context "when reading a assembly" do
      let(:action) do
        { scope: :public, action: :read, subject: :assembly }
      end
      let(:context) { { assembly: assembly } }

      context "when the user is an admin" do
        let(:user) { create :user, :admin }

        it { is_expected.to eq true }
      end

      context "when the assembly is published" do
        let(:user) { create :user, organization: organization }

        it { is_expected.to eq true }
      end

      context "when the assembly is not published" do
        let(:user) { create :user, organization: organization }
        let(:assembly) { create :assembly, :unpublished, organization: organization }

        context "when the user doesn't have access to it" do
          it { is_expected.to eq false }
        end

        context "when the user has access to it" do
          before do
            create :assembly_user_role, user: user, assembly: assembly
          end

          it { is_expected.to eq true }
        end
      end
    end

    context "when listing assemblies" do
      let(:action) do
        { scope: :public, action: :list, subject: :assembly }
      end

      it { is_expected.to eq true }
    end

    context "when listing assembly members" do
      let(:action) do
        { scope: :public, action: :list, subject: :members }
      end

      it { is_expected.to eq true }
    end

    context "when reporting a resource" do
      let(:action) do
        { scope: :public, action: :create, subject: :moderation }
      end

      it { is_expected.to eq true }
    end

    context "when any other action" do
      let(:action) do
        { scope: :public, action: :foo, subject: :bar }
      end

      it_behaves_like "permission is not set"
    end
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
    let(:context) { { space_name: :assemblies } }

    it_behaves_like "access for roles", org_admin: true, admin: true, collaborator: true, moderator: true
  end

  context "when reading the admin dashboard" do
    let(:action) do
      { scope: :admin, action: :read, subject: :admin_dashboard }
    end

    it_behaves_like "access for roles", org_admin: true, admin: true, collaborator: true, moderator: true
  end

  context "when acting on component data" do
    let(:action) do
      { scope: :admin, action: :any_action_is_accepted, subject: :component_data }
    end
    let(:context) { { current_participatory_space: assembly } }

    it_behaves_like "access for roles", org_admin: true, admin: true, collaborator: :not_set, moderator: :not_set
  end

  context "when reading the assemblies list" do
    let(:action) do
      { scope: :admin, action: :read, subject: :assembly_list }
    end

    it_behaves_like "access for roles", org_admin: true, admin: true, collaborator: true, moderator: true
  end

  context "when reading a assembly" do
    let(:action) do
      { scope: :admin, action: :read, subject: :assembly }
    end
    let(:context) { { assembly: assembly } }

    it_behaves_like "access for roles", org_admin: true, admin: true, collaborator: true, moderator: true
  end

  context "when reading a participatory_space" do
    let(:action) do
      { scope: :admin, action: :read, subject: :participatory_space }
    end
    let(:context) { { current_participatory_space: assembly } }

    it_behaves_like "access for roles", org_admin: true, admin: true, collaborator: true, moderator: true
  end

  context "when creating a assembly" do
    let(:action) do
      { scope: :admin, action: :create, subject: :assembly }
    end

    it_behaves_like "access for roles", org_admin: true, admin: false, collaborator: false, moderator: false
  end

  context "when destroying a assembly" do
    let(:action) do
      { scope: :admin, action: :destroy, subject: :assembly }
    end

    it_behaves_like "access for roles", org_admin: true, admin: false, collaborator: false, moderator: false
  end

  context "with a assembly" do
    let(:context) { { assembly: assembly } }

    context "when moderating a resource" do
      let(:action) do
        { scope: :admin, action: :foo, subject: :moderation }
      end

      it_behaves_like "access for roles", org_admin: true, admin: true, collaborator: :not_set, moderator: true
    end

    context "when publishing a assembly" do
      let(:action) do
        { scope: :admin, action: :publish, subject: :assembly }
      end

      it_behaves_like "access for roles", org_admin: true, admin: true, collaborator: :not_set, moderator: :not_set
    end

    context "when user is a collaborator" do
      let(:user) { assembly_collaborator }

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

    context "when user is a assembly admin" do
      let(:user) { assembly_admin }

      context "when creating a assembly" do
        let(:action) do
          { scope: :admin, action: :create, subject: :assembly }
        end

        it { is_expected.to eq false }
      end

      context "when destroying a assembly" do
        let(:action) do
          { scope: :admin, action: :destroy, subject: :assembly }
        end

        it { is_expected.to eq false }
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
      it_behaves_like "allows any action on subject", :assembly
      it_behaves_like "allows any action on subject", :assembly_member
      it_behaves_like "allows any action on subject", :assembly_user_role
    end

    context "when user is n org admin" do
      context "when creating a assembly" do
        let(:action) do
          { scope: :admin, action: :create, subject: :assembly }
        end

        it { is_expected.to eq true }
      end

      context "when destroying a assembly" do
        let(:action) do
          { scope: :admin, action: :destroy, subject: :assembly }
        end

        it { is_expected.to eq true }
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
      it_behaves_like "allows any action on subject", :assembly
      it_behaves_like "allows any action on subject", :assembly_member
      it_behaves_like "allows any action on subject", :assembly_user_role
      it_behaves_like "allows any action on subject", :space_private_user
    end
  end
end
