# frozen_string_literal: true

require "spec_helper"

describe Decidim::Permissions do
  subject { described_class.new(user, permission_action, context).permissions.allowed? }

  let(:user) { nil }
  let(:context) do
    {}
  end
  let(:permission_action) { Decidim::PermissionAction.new(action) }
  let(:action_name) { :foo }
  let(:action_subject) { :bar }
  let(:action) do
    { scope: :public, action: action_name, subject: action_subject }
  end

  context "when reading public pages" do
    let(:action) do
      { scope: :public, action: :read, subject: :public_page }
    end

    it { is_expected.to eq true }
  end

  context "when action is on a locale" do
    let(:action) do
      { scope: :public, action: :foo, subject: :locales }
    end

    it { is_expected.to eq true }
  end

  context "when reading a component" do
    let(:action) do
      { scope: :public, action: :read, subject: :component }
    end
    let(:context) { { current_component: component } }
    let(:organization) { component.participatory_space.organization }

    context "when the component is published" do
      let(:component) { create :component, :published }

      it { is_expected.to eq true }
    end

    context "when the component is not published" do
      let(:component) { create :component, :unpublished }

      context "when the user does not exist" do
        it { is_expected.to eq false }
      end

      context "when the user has no admin access" do
        let(:user) { create :user, organization: organization }

        it { is_expected.to eq false }
      end

      context "when the user is an admin" do
        let(:user) { create :user, :admin, organization: organization }

        it { is_expected.to eq true }
      end

      context "when the space gives the user admin access" do
        let(:user) { create :process_admin, participatory_process: component.participatory_space }

        it { is_expected.to eq true }
      end
    end
  end

  context "when action is on a scope" do
    let(:action_subject) { :scope }

    context "when picking" do
      let(:action_name) { :pick }

      it { is_expected.to eq true }
    end

    context "when searching" do
      let(:action_name) { :search }

      it { is_expected.to eq true }
    end

    context "when any other action" do
      let(:action_name) { :foo }

      it { is_expected.to eq false }
    end
  end

  context "when any other subject or action" do
    let(:action) do
      { scope: :public, action: :foo, subject: :bar }
    end

    it_behaves_like "permission is not set"
  end

  context "with a user" do
    let(:user) { create :user }

    context "when user is a user manager" do
      let(:user) { create :user, :user_manager }

      it_behaves_like "delegates permissions to", Decidim::UserManagerPermissions
    end

    context "when managing self user" do
      let(:action_subject) { :user }
      let(:context) { { current_user: current_user } }

      context "when user is self" do
        let(:current_user) { user }

        it { is_expected.to eq true }
      end

      context "when user is not self" do
        let(:current_user) { create :user }

        it { is_expected.to eq false }
      end
    end

    context "when action is on follows" do
      let(:action_subject) { :follow }

      context "when following a resource" do
        let(:action_name) { :create }

        it { is_expected.to eq true }
      end

      context "when any other action on a follow" do
        let(:action_name) { :foo }
        let(:context) { { follow: follow } }

        context "when the author of the follow is the user" do
          let(:follow) { create :follow, user: user }

          it { is_expected.to eq true }
        end

        context "when the author of the follow is another user" do
          let(:follow) { create :follow }

          it { is_expected.to eq false }
        end
      end
    end

    context "when action is on notifications" do
      let(:action_subject) { :notification }

      context "when reading a notification" do
        let(:action_name) { :read }

        it { is_expected.to eq true }
      end

      context "when any other action on a notification" do
        let(:action_name) { :foo }
        let(:context) { { notification: notification } }

        context "when the notification is sent to the user" do
          let(:notification) { build :notification, user: user }

          it { is_expected.to eq true }
        end

        context "when the notification is sent to another user" do
          let(:notification) { build :notification }

          it { is_expected.to eq false }
        end
      end
    end

    context "when action is on conversations" do
      let(:action_subject) { :conversation }

      context "when listing conversations" do
        let(:action_name) { :list }

        it { is_expected.to eq true }
      end

      context "when creating a conversation" do
        let(:action_name) { :create }

        it { is_expected.to eq true }
      end

      context "when any other action on a conversation" do
        let(:action_name) { :foo }
        let(:context) { { conversation: conversation } }
        let(:another_user) { create :user }

        context "when the originator of the conversation is the user" do
          let!(:conversation) do
            Decidim::Messaging::Conversation.start!(
              originator: user,
              interlocutors: [another_user],
              body: "who wants apples?"
            )
          end

          it { is_expected.to eq true }
        end

        context "when the user is an interlocutor" do
          let!(:conversation) do
            Decidim::Messaging::Conversation.start!(
              originator: another_user,
              interlocutors: [user],
              body: "who wants apples?"
            )
          end

          it { is_expected.to eq true }
        end

        context "when the user is not in the conversation" do
          let!(:conversation) do
            Decidim::Messaging::Conversation.start!(
              originator: another_user,
              interlocutors: [create(:user)],
              body: "who wants apples?"
            )
          end

          it { is_expected.to eq false }
        end
      end
    end

    context "when action is on user group" do
      let(:action_subject) { :user_group }

      context "when creating user groups" do
        let(:action_name) { :create }

        it { is_expected.to eq true }
      end
    end
  end
end
