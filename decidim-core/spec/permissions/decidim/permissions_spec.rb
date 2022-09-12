# frozen_string_literal: true

require "spec_helper"

describe Decidim::Permissions do
  subject { described_class.new(user, permission_action, context).permissions.allowed? }

  let(:user) { nil }
  let(:context) do
    {}
  end
  let(:permission_action) { Decidim::PermissionAction.new(**action) }
  let(:action_name) { :foo }
  let(:action_subject) { :bar }
  let(:action) do
    { scope: :public, action: action_name, subject: action_subject }
  end

  context "when reading public pages" do
    let(:action) do
      { scope: :public, action: :read, subject: :public_page }
    end

    it { is_expected.to be true }
  end

  context "when action is on a locale" do
    let(:action) do
      { scope: :public, action: :foo, subject: :locales }
    end

    it { is_expected.to be true }
  end

  context "when reporting a resource" do
    let(:action) do
      { scope: :public, action: :create, subject: :moderation }
    end

    it { is_expected.to be true }
  end

  context "when reading a component" do
    let(:action) do
      { scope: :public, action: :read, subject: :component }
    end
    let(:context) { { current_component: component } }
    let(:organization) { component.participatory_space.organization }

    context "when the component is published" do
      let(:component) { create :component, :published }

      it { is_expected.to be true }
    end

    context "when the component is not published" do
      let(:component) { create :component, :unpublished }

      context "when the user does not exist" do
        context "when a share token is provided" do
          let(:share_token) { create :share_token, token_for: component, organization: component.organization }
          let(:context) { { share_token: share_token.token, current_component: component } }

          it { is_expected.to be true }
        end

        context "when an invalid share token is provided" do
          let(:share_token) { create :share_token, :expired, token_for: component, organization: component.organization }
          let(:context) { { share_token: share_token.token, current_component: component } }

          it { is_expected.to be false }
        end

        context "when no share token is provided" do
          it { is_expected.to be false }
        end
      end

      context "when the user has no admin access" do
        let(:user) { create :user, organization: organization }

        it { is_expected.to be false }
      end

      context "when the user is an admin" do
        let(:user) { create :user, :admin, organization: organization }

        it { is_expected.to be true }
      end

      context "when the space gives the user admin access" do
        let(:user) { create :process_admin, participatory_process: component.participatory_space }

        it { is_expected.to be true }
      end
    end
  end

  context "when action is on a scope" do
    let(:action_subject) { :scope }

    context "when picking" do
      let(:action_name) { :pick }

      it { is_expected.to be true }
    end

    context "when searching" do
      let(:action_name) { :search }

      it { is_expected.to be true }
    end

    context "when any other action" do
      let(:action_name) { :foo }

      it { is_expected.to be false }
    end
  end

  context "when any other subject or action" do
    let(:action) do
      { scope: :public, action: :foo, subject: :bar }
    end

    it_behaves_like "permission is not set"
  end

  context "when subject is an authorization" do
    let(:context) { { authorization: authorization } }
    let(:user) { authorization.user }
    let(:action_name) { nil }
    let(:action) do
      { scope: :public, action: action_name, subject: :authorization }
    end

    context "with a create action" do
      let(:authorization) { build(:authorization) }
      let(:action_name) { :create }

      it { is_expected.to be true }
    end

    context "with an update action" do
      let(:action_name) { :update }

      context "and the authorization is granted" do
        let(:authorization) { create(:authorization, :granted) }

        it { is_expected.to be false }
      end

      context "and the authorization is pending" do
        let(:authorization) { create(:authorization, :pending) }

        it { is_expected.to be true }
      end
    end

    context "with a destroy action" do
      let(:action_name) { :destroy }

      context "and the authorization is granted" do
        let(:authorization) { create(:authorization, :granted) }

        it { is_expected.to be false }
      end

      context "and the authorization is pending" do
        let(:authorization) { create(:authorization, :pending) }

        it { is_expected.to be true }
      end
    end

    context "with a renew action" do
      before do
        allow(authorization).to receive(:renewable?).and_return(true)
      end

      let(:action_name) { :renew }

      context "and the authorization is granted" do
        let(:authorization) { create(:authorization, :granted) }

        it { is_expected.to be true }
      end

      context "and the authorization is pending" do
        let(:authorization) { create(:authorization, :pending) }

        it { is_expected.to be false }
      end
    end
  end

  context "when an amend action" do
    let(:component) { create :component, :published, organization: user.organization, settings: settings }
    let(:settings) { { amendments_enabled: amendments_enabled } }
    let(:amendment) { create :amendment }
    let(:user) { amendment.amender }
    let(:context) { { current_component: component } }
    let(:action_name) { nil }
    let(:action) do
      { scope: :public, action: action_name, subject: :amendment }
    end

    context "with amendments enabled settings" do
      let(:amendments_enabled) { true }

      context "with a create action" do
        let(:action_name) { :create }

        it { is_expected.to be true }
      end

      context "with a accept action" do
        let(:action_name) { :accept }

        it { is_expected.to be true }
      end

      context "with a reject action" do
        let(:action_name) { :reject }

        it { is_expected.to be true }
      end

      context "with a promote action" do
        let(:action_name) { :promote }

        it { is_expected.to be true }
      end
    end

    context "with amendments disabled" do
      let(:amendments_enabled) { false }

      context "with a create action" do
        let(:action_name) { :create }

        it { is_expected.to be false }
      end

      context "with a accept action" do
        let(:action_name) { :accept }

        it { is_expected.to be false }
      end

      context "with a reject action" do
        let(:action_name) { :reject }

        it { is_expected.to be false }
      end

      context "with a promote action" do
        let(:action_name) { :promote }

        it { is_expected.to be false }
      end
    end
  end

  context "with a user" do
    let(:user) { create :user }
    let(:component) { create :component, :published, organization: user.organization }
    let(:context) { { current_component: component } }

    context "when user is a user manager" do
      let(:user) { create :user, :user_manager }

      context "when reading the admin dashboard" do
        let(:action) do
          { scope: :public, action: :read, subject: :admin_dashboard }
        end

        it { is_expected.to be true }
      end

      context "when impersonating a managed user" do
        let(:action) do
          { scope: :public, action: :impersonate, subject: :managed_user }
        end

        it { is_expected.to be true }
      end
    end

    context "when managing self user" do
      let(:action_subject) { :user }
      let(:context) { { current_user: current_user } }

      context "when user is self" do
        let(:current_user) { user }

        it { is_expected.to be true }
      end

      context "when user is not self" do
        let(:current_user) { create :user }

        it { is_expected.to be false }
      end
    end

    context "when action is on follows" do
      let(:action_subject) { :follow }

      context "when following a resource" do
        let(:action_name) { :create }

        it { is_expected.to be true }
      end

      context "when any other action on a follow" do
        let(:action_name) { :foo }
        let(:context) { { follow: follow } }

        context "when the author of the follow is the user" do
          let(:follow) { create :follow, user: user }

          it { is_expected.to be true }
        end

        context "when the author of the follow is another user" do
          let(:follow) { create :follow }

          it { is_expected.to be false }
        end
      end
    end

    it_behaves_like "with endorsable permissions can perform actions related to endorsable"

    context "when action is on notifications" do
      let(:action_subject) { :notification }

      context "when reading a notification" do
        let(:action_name) { :read }

        it { is_expected.to be true }
      end

      context "when any other action on a notification" do
        let(:action_name) { :foo }
        let(:context) { { notification: notification } }

        context "when the notification is sent to the user" do
          let(:notification) { build :notification, user: user }

          it { is_expected.to be true }
        end

        context "when the notification is sent to another user" do
          let(:notification) { build :notification }

          it { is_expected.to be false }
        end
      end
    end

    context "when action is on conversations" do
      let(:action_subject) { :conversation }
      let(:interlocutor) { nil }

      context "when listing conversations" do
        let(:action_name) { :list }

        it { is_expected.to be true }
      end

      context "when creating a conversation" do
        let(:action_name) { :create }

        it_behaves_like "restricted conversation permissions"
      end

      context "when updating a conversation" do
        let(:action_name) { :update }

        it_behaves_like "restricted conversation permissions"
      end

      context "when any other action on a conversation" do
        let(:action_name) { :foo }

        it_behaves_like "general conversation permissions"
      end
    end

    context "when action is on user group" do
      let(:action_subject) { :user_group }

      context "when creating user groups" do
        let(:action_name) { :create }

        it { is_expected.to be true }
      end

      context "when joining user groups" do
        let(:action_name) { :join }

        it { is_expected.to be true }
      end

      context "when leaving a user group" do
        let(:action_name) { :leave }
        let(:user) { create :user, :confirmed }
        let!(:user_group) { create :user_group, users: [user], organization: user.organization }
        let(:context) { { user_group: user_group } }

        context "when the user does not belong to the user group" do
          let!(:user_group) { create :user_group, organization: user.organization }

          it { is_expected.to be false }
        end

        context "when the user is the creator" do
          it { is_expected.to be true }
        end

        context "when the user belongs to the group" do
          before do
            membership = Decidim::UserGroupMembership.find_by(user: user, user_group: user_group)
            membership.role = :admin
            membership.save
          end

          it { is_expected.to be true }
        end
      end

      context "when managing user groups" do
        let(:action_name) { :manage }
        let(:user) { create :user, :confirmed }
        let!(:user_group) { create :user_group, users: [user], organization: user.organization }
        let(:context) { { user_group: user_group } }

        context "when the user is the creator" do
          it { is_expected.to be true }
        end

        context "when the user is an admin" do
          before do
            membership = Decidim::UserGroupMembership.find_by(user: user, user_group: user_group)
            membership.role = :admin
            membership.save
          end

          it { is_expected.to be true }
        end

        context "when the user is a basic member" do
          before do
            membership = Decidim::UserGroupMembership.find_by(user: user, user_group: user_group)
            membership.role = :member
            membership.save
          end

          it { is_expected.to be false }
        end
      end
    end

    context "when action is on user group invitations" do
      let(:action_subject) { :user_group_invitations }

      context "when action is create" do
        let(:action_name) { :create }

        it { is_expected.to be true }
      end

      context "when action is reject" do
        let(:action_name) { :reject }

        it { is_expected.to be true }
      end
    end
  end
end
