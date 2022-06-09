# frozen_string_literal: true

require "spec_helper"

describe Decidim::Assemblies::Permissions do
  subject { described_class.new(user, permission_action, context).permissions.allowed? }

  let(:user) { create :user, :admin, organization: organization }
  let(:organization) { create :organization }
  let(:assembly_type) { create :assemblies_type, organization: organization }
  let(:assemblies_setting) { create :assemblies_setting, organization: organization }
  let(:assembly) { create :assembly, organization: organization, assembly_type: assembly_type }
  let(:context) { {} }
  let(:permission_action) { Decidim::PermissionAction.new(**action) }
  let(:assembly_admin) { create :assembly_admin, assembly: assembly }
  let(:assembly_collaborator) { create :assembly_collaborator, assembly: assembly }
  let(:assembly_moderator) { create :assembly_moderator, assembly: assembly }
  let(:assembly_valuator) { create :assembly_valuator, assembly: assembly }

  shared_examples "access for role" do |access|
    case access
    when true
      it { is_expected.to be true }
    when :not_set
      it_behaves_like "permission is not set"
    else
      it { is_expected.to be false }
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

    context "when user is a space valuator" do
      let(:user) { assembly_valuator }

      it_behaves_like "access for role", access[:valuator]
    end
  end

  context "when the action is for the public part" do
    context "when reading the admin dashboard" do
      let(:action) do
        { scope: :admin, action: :read, subject: :admin_dashboard }
      end

      it_behaves_like(
        "access for roles",
        org_admin: true,
        admin: true,
        collaborator: true,
        moderator: true,
        valuator: true
      )
    end

    context "when reading a assembly" do
      let(:action) do
        { scope: :public, action: :read, subject: :assembly }
      end
      let(:context) { { assembly: assembly } }

      context "when the user is an admin" do
        let(:user) { create :user, :admin }

        it { is_expected.to be true }
      end

      context "when the assembly is published" do
        let(:user) { create :user, organization: organization }

        it { is_expected.to be true }
      end

      context "when the assembly is not published" do
        let(:user) { create :user, organization: organization }
        let(:assembly) { create :assembly, :unpublished, organization: organization }

        context "when the user doesn't have access to it" do
          it { is_expected.to be false }
        end

        context "when the user has access to it" do
          before do
            create :assembly_user_role, user: user, assembly: assembly
          end

          it { is_expected.to be true }
        end
      end
    end

    context "when listing assemblies" do
      let(:action) do
        { scope: :public, action: :list, subject: :assembly }
      end

      it { is_expected.to be true }
    end

    context "when listing assembly members" do
      let(:action) do
        { scope: :public, action: :list, subject: :members }
      end

      it { is_expected.to be true }
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

    it_behaves_like(
      "access for roles",
      org_admin: true,
      admin: true,
      collaborator: true,
      moderator: true,
      valuator: true
    )
  end

  context "when reading the admin dashboard from the admin part" do
    let(:action) do
      { scope: :admin, action: :read, subject: :admin_dashboard }
    end

    it_behaves_like(
      "access for roles",
      org_admin: true,
      admin: true,
      collaborator: true,
      moderator: true,
      valuator: true
    )
  end

  context "when acting on component data" do
    context "when exporting component data" do
      let(:action) do
        { scope: :admin, action: :export, subject: :component_data }
      end
      let(:context) { { current_participatory_space: assembly } }

      it_behaves_like(
        "access for roles",
        org_admin: true,
        admin: true,
        collaborator: :not_set,
        moderator: :not_set,
        valuator: true
      )
    end

    context "when performing any other action" do
      let(:action) do
        { scope: :admin, action: :any_action_is_accepted, subject: :component_data }
      end
      let(:context) { { current_participatory_space: assembly } }

      it_behaves_like(
        "access for roles",
        org_admin: true,
        admin: true,
        collaborator: :not_set,
        moderator: :not_set,
        valuator: :not_set
      )
    end
  end

  context "when reading the assemblies list" do
    let(:action) do
      { scope: :admin, action: :read, subject: :assembly_list }
    end

    it_behaves_like(
      "access for roles",
      org_admin: true,
      admin: true,
      collaborator: true,
      moderator: true,
      valuator: true
    )
  end

  context "when reading an assembly" do
    let(:action) do
      { scope: :admin, action: :read, subject: :assembly }
    end
    let(:context) { { assembly: assembly } }

    it_behaves_like(
      "access for roles",
      org_admin: true,
      admin: true,
      collaborator: true,
      moderator: true,
      valuator: true
    )
  end

  context "when reading a participatory_space" do
    let(:action) do
      { scope: :admin, action: :read, subject: :participatory_space }
    end
    let(:context) { { current_participatory_space: assembly } }

    it_behaves_like(
      "access for roles",
      org_admin: true,
      admin: true,
      collaborator: true,
      moderator: true,
      valuator: true
    )
  end

  context "when creating a assembly" do
    let(:action) do
      { scope: :admin, action: :create, subject: :assembly }
    end

    it_behaves_like(
      "access for roles",
      org_admin: true,
      admin: true,
      collaborator: false,
      moderator: false,
      valuator: false
    )
  end

  context "when exporting an assembly" do
    let(:action) do
      { scope: :admin, action: :export, subject: :assembly }
    end

    it_behaves_like(
      "access for roles",
      org_admin: true,
      admin: false,
      collaborator: false,
      moderator: false,
      valuator: false
    )
  end

  context "when copying an assembly" do
    let(:action) do
      { scope: :admin, action: :copy, subject: :assembly }
    end

    it_behaves_like(
      "access for roles",
      org_admin: true,
      admin: false,
      collaborator: false,
      moderator: false,
      valuator: false
    )
  end

  context "when reading a assemblies settings" do
    let(:action) do
      { scope: :admin, action: :read, subject: :assemblies_setting }
    end

    it_behaves_like(
      "access for roles",
      org_admin: true,
      admin: false,
      collaborator: false,
      moderator: false,
      valuator: false
    )
  end

  context "with a assembly" do
    let(:context) { { assembly: assembly } }

    context "when moderating a resource" do
      let(:action) do
        { scope: :admin, action: :foo, subject: :moderation }
      end

      it_behaves_like(
        "access for roles",
        org_admin: true,
        admin: true,
        collaborator: :not_set,
        valuator: :not_set,
        moderator: true
      )
    end

    context "when publishing a assembly" do
      let(:action) do
        { scope: :admin, action: :publish, subject: :assembly }
      end

      it_behaves_like(
        "access for roles",
        org_admin: true,
        admin: true,
        collaborator: :not_set,
        valuator: :not_set,
        moderator: :not_set
      )
    end

    context "when user is a collaborator" do
      let(:user) { assembly_collaborator }

      context "when action is :read" do
        let(:action) do
          { scope: :admin, action: :read, subject: :dummy }
        end

        it { is_expected.to be true }
      end

      context "when action is :preview" do
        let(:action) do
          { scope: :admin, action: :preview, subject: :dummy }
        end

        it { is_expected.to be true }
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

        it { is_expected.to be true }
      end

      shared_examples "allows any action on subject" do |action_subject|
        context "when action subject is #{action_subject}" do
          let(:action) do
            { scope: :admin, action: :foo, subject: action_subject }
          end

          it { is_expected.to be true }
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

    context "when user is an org admin" do
      context "when creating a assembly" do
        let(:action) do
          { scope: :admin, action: :create, subject: :assembly }
        end

        it { is_expected.to be true }
      end

      shared_examples "allows any action on subject" do |action_subject|
        context "when action subject is #{action_subject}" do
          let(:action) do
            { scope: :admin, action: :foo, subject: action_subject }
          end

          it { is_expected.to be true }
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
      it_behaves_like "allows any action on subject", :assemblies_setting
    end
  end

  describe "assemblies types" do
    context "when action is :index" do
      let(:action) do
        { scope: :admin, action: :index, subject: :assembly_type }
      end

      it { is_expected.to be true }
    end

    context "when action is :create" do
      let(:action) do
        { scope: :admin, action: :create, subject: :assembly_type }
      end

      it { is_expected.to be true }
    end

    context "when action is :edit" do
      let(:action) do
        { scope: :admin, action: :edit, subject: :assembly_type }
      end

      it { is_expected.to be true }
    end

    context "when action is :destroy" do
      let(:context) { { assembly_type: assembly_type } }
      let(:action) do
        { scope: :admin, action: :destroy, subject: :assembly_type }
      end

      context "and assembly type has children" do
        let!(:assembly) { create :assembly, organization: organization, assembly_type: assembly_type }

        it { is_expected.to be false }
      end

      context "and assembly type has no children" do
        let(:assembly) { create :assembly, organization: organization }

        it { is_expected.to be true }
      end
    end

    context "when user is not an admin" do
      let(:user) { assembly_collaborator }

      let(:action) do
        { scope: :admin, action: :create, subject: :assembly_type }
      end

      it { is_expected.to be false }
    end

    context "when listing assemblies list" do
      let!(:user) { create :user, organization: organization }
      let(:context) { { assembly: assembly } }

      context "when assembly is a root assembly" do
        before do
          create :assembly_user_role, user: user, assembly: assembly
        end

        let(:action) do
          { scope: :admin, action: :list, subject: :assembly }
        end

        it { is_expected.to be(true) }
      end

      context "when the assembly has one ancestor" do
        before do
          create :assembly_user_role, user: user, assembly: child_assembly
        end

        let(:child_assembly) { create :assembly, parent: assembly, organization: organization }
        let(:action) do
          { scope: :admin, action: :list, subject: :assembly }
        end

        it { is_expected.to be(true) }
      end

      context "when the assembly has more than one ancestor" do
        before do
          create :assembly_user_role, user: user, assembly: grand_child_assembly
        end

        let(:child_assembly) { create :assembly, parent: assembly, organization: organization }
        let(:grand_child_assembly) { create :assembly, parent: child_assembly, organization: organization }
        let(:action) do
          { scope: :admin, action: :list, subject: :assembly }
        end

        it { is_expected.to be(true) }
      end

      context "when the assembly has one sucessor" do
        before do
          create :assembly_user_role, user: user, assembly: assembly.parent
        end

        let!(:assembly) { create :assembly, :with_parent, organization: organization }
        let(:action) do
          { scope: :admin, action: :list, subject: :assembly }
        end

        it { is_expected.to be(true) }
      end
    end
  end

  describe "when acting with assemblies admins and children assemblies" do
    let!(:user) { create :assembly_admin, assembly: mother_assembly }
    let(:mother_assembly) { create :assembly, parent: assembly, organization: organization, hashtag: "mother" }
    let(:child_assembly) { create :assembly, parent: mother_assembly, organization: organization, hashtag: "child" }

    context "when assembly is a grandmother assembly" do
      let(:context) { { assembly: assembly } }

      context "and action is :list" do
        let(:action) do
          { scope: :admin, action: :list, subject: :assembly }
        end

        it { is_expected.to be(true) }
      end

      context "and action is :export" do
        let(:action) do
          { scope: :admin, action: :export, subject: :assembly }
        end

        it { is_expected.to be(false) }
      end

      context "and action is :copy" do
        let(:action) do
          { scope: :admin, action: :copy, subject: :assembly }
        end

        it { is_expected.to be(false) }
      end
    end

    context "when assembly is a mother assembly" do
      let(:context) { { assembly: mother_assembly } }

      context "and action is :list" do
        let(:action) do
          { scope: :admin, action: :list, subject: :assembly }
        end

        it { is_expected.to be(true) }
      end

      context "and action is :export" do
        let(:action) do
          { scope: :admin, action: :export, subject: :assembly }
        end

        it { is_expected.to be(true) }
      end

      context "and action is :copy" do
        let(:action) do
          { scope: :admin, action: :copy, subject: :assembly }
        end

        it { is_expected.to be(true) }
      end
    end

    context "when assembly is a child assembly" do
      let(:context) { { assembly: child_assembly } }

      context "and action is :list" do
        let(:action) do
          { scope: :admin, action: :list, subject: :assembly }
        end

        it { is_expected.to be(true) }
      end

      context "and action is :export" do
        let(:action) do
          { scope: :admin, action: :export, subject: :assembly }
        end

        it { is_expected.to be(true) }
      end

      context "and action is :copy" do
        let(:action) do
          { scope: :admin, action: :copy, subject: :assembly }
        end

        it { is_expected.to be(true) }
      end

      context "and action is :read the current assembly" do
        let(:action) do
          { scope: :admin, action: :read, subject: :assembly }
        end

        it { is_expected.to be(true) }
      end
    end
  end
end
