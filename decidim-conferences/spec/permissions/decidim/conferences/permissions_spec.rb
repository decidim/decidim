# frozen_string_literal: true

require "spec_helper"

describe Decidim::Conferences::Permissions do
  subject { described_class.new(user, permission_action, context).permissions.allowed? }

  let(:user) { create(:user, :admin, organization:) }
  let(:organization) { create(:organization) }
  let(:conference) { create(:conference, organization:) }
  let(:context) { {} }
  let(:permission_action) { Decidim::PermissionAction.new(**action) }
  let(:conference_admin) { create(:conference_admin, conference:) }
  let(:conference_collaborator) { create(:conference_collaborator, conference:) }
  let(:conference_moderator) { create(:conference_moderator, conference:) }
  let(:conference_valuator) { create(:conference_valuator, conference:) }

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
      let(:user) { conference_admin }

      it_behaves_like "access for role", access[:admin]
    end

    context "when user is a space collaborator" do
      let(:user) { conference_collaborator }

      it_behaves_like "access for role", access[:collaborator]
    end

    context "when user is a space moderator" do
      let(:user) { conference_moderator }

      it_behaves_like "access for role", access[:moderator]
    end

    context "when user is a space valuator" do
      let(:user) { conference_valuator }

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
        valuator: true,
        moderator: true
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

    context "when reading a conference" do
      let(:action) do
        { scope: :public, action: :read, subject: :conference }
      end
      let(:context) { { conference: } }

      context "when the user is an admin" do
        let(:user) { create(:user, :admin) }

        it { is_expected.to be true }
      end

      context "when the conference is published" do
        let(:user) { create(:user, organization:) }

        it { is_expected.to be true }
      end

      context "when the conference is not published" do
        let(:user) { create(:user, organization:) }
        let(:conference) { create(:conference, :unpublished, organization:) }

        context "when the user does not have access to it" do
          it { is_expected.to be false }
        end

        context "when the user has access to it" do
          before do
            create(:conference_user_role, user:, conference:)
          end

          it { is_expected.to be true }
        end
      end
    end

    context "when listing conferences" do
      let(:action) do
        { scope: :public, action: :list, subject: :conference }
      end

      it { is_expected.to be true }
    end

    context "when listing conference speakers" do
      let(:action) do
        { scope: :public, action: :list, subject: :speakers }
      end

      it { is_expected.to be true }
    end

    context "when conference program" do
      let(:action) do
        { scope: :public, action: :list, subject: :program }
      end

      it { is_expected.to be true }
    end

    context "when listing media links" do
      let(:action) do
        { scope: :public, action: :list, subject: :media_links }
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
    let(:context) { { space_name: :conferences } }

    it_behaves_like(
      "access for roles",
      org_admin: true,
      admin: true,
      collaborator: true,
      valuator: true,
      moderator: true
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
      valuator: true,
      moderator: true
    )
  end

  context "when acting on component data" do
    context "when exporting component data" do
      let(:action) do
        { scope: :admin, action: :export, subject: :component_data }
      end
      let(:context) { { current_participatory_space: conference } }

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
      let(:context) { { current_participatory_space: conference } }

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

  context "when reading the conferences list" do
    let(:action) do
      { scope: :admin, action: :read, subject: :conference_list }
    end

    it_behaves_like(
      "access for roles",
      org_admin: true,
      admin: true,
      collaborator: true,
      valuator: true,
      moderator: true
    )
  end

  context "when uploading editor images" do
    let(:action) do
      { scope: :admin, action: :create, subject: :editor_image }
    end
    let(:context) { { space_name: :conferences } }

    it_behaves_like(
      "access for roles",
      org_admin: true,
      admin: true,
      collaborator: true,
      moderator: true,
      valuator: true
    )
  end

  context "when reading a conference" do
    let(:action) do
      { scope: :admin, action: :read, subject: :conference }
    end
    let(:context) { { conference: } }

    it_behaves_like(
      "access for roles",
      org_admin: true,
      admin: true,
      collaborator: true,
      valuator: true,
      moderator: true
    )
  end

  context "when reading a participatory_space" do
    let(:action) do
      { scope: :admin, action: :read, subject: :participatory_space }
    end
    let(:context) { { current_participatory_space: conference } }

    it_behaves_like(
      "access for roles",
      org_admin: true,
      admin: true,
      collaborator: true,
      valuator: true,
      moderator: true
    )
  end

  context "when creating a conference" do
    let(:action) do
      { scope: :admin, action: :create, subject: :conference }
    end

    it_behaves_like(
      "access for roles",
      org_admin: true,
      admin: false,
      collaborator: false,
      valuator: false,
      moderator: false
    )
  end

  context "with a conference" do
    let(:context) { { conference: } }

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

    context "when publishing a conference" do
      let(:action) do
        { scope: :admin, action: :publish, subject: :conference }
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
      let(:user) { conference_collaborator }

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

    context "when user is a conference admin" do
      let(:user) { conference_admin }

      context "when creating a conference" do
        let(:action) do
          { scope: :admin, action: :create, subject: :conference }
        end

        it { is_expected.to be false }
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
      it_behaves_like "allows any action on subject", :conference
      it_behaves_like "allows any action on subject", :conference_speaker
      it_behaves_like "allows any action on subject", :partner
      it_behaves_like "allows any action on subject", :registration_type
      it_behaves_like "allows any action on subject", :conference_user_role
    end

    context "when user is n org admin" do
      context "when creating a conference" do
        let(:action) do
          { scope: :admin, action: :create, subject: :conference }
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
      it_behaves_like "allows any action on subject", :conference
      it_behaves_like "allows any action on subject", :conference_speaker
      it_behaves_like "allows any action on subject", :partner
      it_behaves_like "allows any action on subject", :registration_type
      it_behaves_like "allows any action on subject", :conference_user_role
    end
  end
end
