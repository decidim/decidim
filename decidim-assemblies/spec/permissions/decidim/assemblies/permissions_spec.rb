# frozen_string_literal: true

require "spec_helper"

describe Decidim::Assemblies::Permissions do
  subject { described_class.new(user, permission_action, context).permissions.allowed? }

  let(:user) { create(:user, :admin, organization:) }
  let(:organization) { create(:organization) }
  let(:assembly) { create(:assembly, organization:) }
  let(:context) { {} }
  let(:permission_action) { Decidim::PermissionAction.new(**action) }
  let(:assembly_admin) { create(:assembly_admin, assembly:) }
  let(:assembly_collaborator) { create(:assembly_collaborator, assembly:) }
  let(:assembly_moderator) { create(:assembly_moderator, assembly:) }
  let(:assembly_valuator) { create(:assembly_valuator, assembly:) }

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

    context "when accessing global moderation" do
      subject { Decidim::Admin::Permissions.new(user, permission_action, context).permissions.allowed? }

      let(:action) do
        { scope: :admin, action: :read, subject: :global_moderation }
      end

      it_behaves_like(
        "access for roles",
        org_admin: true,
        admin: true,
        collaborator: false,
        moderator: true,
        valuator: false
      )
    end

    context "when reading an assembly" do
      let(:action) do
        { scope: :public, action: :read, subject: :assembly }
      end
      let(:context) { { assembly: } }

      context "when the user is an admin" do
        let(:user) { create(:user, :admin) }

        it { is_expected.to be true }
      end

      context "when the assembly is published" do
        let(:user) { create(:user, organization:) }

        it { is_expected.to be true }
      end

      context "when the assembly is not published" do
        let(:user) { create(:user, organization:) }
        let(:assembly) { create(:assembly, :unpublished, organization:) }

        context "when the user does not have access to it" do
          it { is_expected.to be false }
        end

        context "when the user has access to it" do
          before do
            create(:assembly_user_role, user:, assembly:)
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

  context "when uploading editor images" do
    let(:action) do
      { scope: :admin, action: :create, subject: :editor_image }
    end
    let(:context) { { assembly: } }

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
    let(:context) { { assembly: } }

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

  context "when creating an assembly" do
    let(:action) do
      { scope: :admin, action: :create, subject: :assembly }
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

  context "with an assembly" do
    let(:context) { { assembly: } }

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

    context "when publishing an assembly" do
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

    context "when user is an assembly admin" do
      let(:user) { assembly_admin }

      context "when creating an assembly" do
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
      it_behaves_like "allows any action on subject", :component
      it_behaves_like "allows any action on subject", :moderation
      it_behaves_like "allows any action on subject", :assembly
      it_behaves_like "allows any action on subject", :assembly_user_role

      context "when private assembly" do
        let(:assembly) { create(:assembly, organization:, private_space: true) }
        let!(:context) { { current_participatory_space: assembly } }

        it_behaves_like "allows any action on subject", :space_private_user
      end
    end

    context "when user is an org admin" do
      context "when creating an assembly" do
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
      it_behaves_like "allows any action on subject", :component
      it_behaves_like "allows any action on subject", :moderation
      it_behaves_like "allows any action on subject", :assembly
      it_behaves_like "allows any action on subject", :assembly_user_role

      context "when private assembly" do
        let(:assembly) { create(:assembly, organization:, private_space: true) }
        let!(:context) { { current_participatory_space: assembly } }

        it_behaves_like "allows any action on subject", :space_private_user
      end
    end
  end

  context "when listing assemblies list" do
    let!(:user) { create(:user, organization:) }
    let(:context) { { assembly: } }

    context "when assembly is a root assembly" do
      before do
        create(:assembly_user_role, user:, assembly:)
      end

      let(:action) do
        { scope: :admin, action: :list, subject: :assembly }
      end

      it { is_expected.to be(true) }
    end

    context "when the assembly has one ancestor" do
      before do
        create(:assembly_user_role, user:, assembly: child_assembly)
      end

      let(:child_assembly) { create(:assembly, parent: assembly, organization:) }
      let(:action) do
        { scope: :admin, action: :list, subject: :assembly }
      end

      it { is_expected.to be(true) }
    end

    context "when the assembly has more than one ancestor" do
      before do
        create(:assembly_user_role, user:, assembly: grand_child_assembly)
      end

      let(:child_assembly) { create(:assembly, parent: assembly, organization:) }
      let(:grand_child_assembly) { create(:assembly, parent: child_assembly, organization:) }
      let(:action) do
        { scope: :admin, action: :list, subject: :assembly }
      end

      it { is_expected.to be(true) }
    end

    context "when the assembly has one successor" do
      before do
        create(:assembly_user_role, user:, assembly: assembly.parent)
      end

      let!(:assembly) { create(:assembly, :with_parent, organization:) }
      let(:action) do
        { scope: :admin, action: :list, subject: :assembly }
      end

      it { is_expected.to be(true) }
    end
  end

  describe "when acting with assemblies admins and children assemblies" do
    let!(:user) { create(:assembly_admin, assembly: mother_assembly) }
    let(:mother_assembly) { create(:assembly, parent: assembly, organization:, hashtag: "mother") }
    let(:child_assembly) { create(:assembly, parent: mother_assembly, organization:, hashtag: "child") }

    context "when assembly is a grandmother assembly" do
      let(:context) { { assembly: } }

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
