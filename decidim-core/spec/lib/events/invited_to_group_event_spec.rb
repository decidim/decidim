# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe InvitedToGroupEvent do
    include_context "when a simple event"

    let(:user_group) { create(:user_group, users: []) }
    let!(:membership) { create(:user_group_membership, user:, user_group:, role: :member) }
    let(:extra) { { user_group_name: user_group.name, user_group_nickname: user_group.nickname, membership_id: membership.id } }
    let(:event_name) { "decidim.events.groups.invited_to_group" }
    let(:resource) { user_group }
    let(:resource_path) do
      Decidim::Core::Engine.routes.url_helpers.profile_path(resource.nickname)
    end
    let(:groups_tab_path) do
      Decidim::Core::Engine.routes.url_helpers.profile_groups_path(user.nickname)
    end

    it_behaves_like "a simple event", skip_space_checks: true

    describe "email_subject" do
      it "is generated correctly" do
        expect(subject.email_subject).to include("You have been invited")
      end
    end

    describe "email_intro" do
      it "is generated correctly" do
        expect(subject.email_intro).to include(resource_path)
      end
    end

    describe "notification_title" do
      it "is generated correctly" do
        expect(subject.notification_title).to include(groups_tab_path)
      end
    end

    describe "user_group_nickname" do
      it "returns the user group nickname" do
        expect(subject.user_group_nickname).to eq(user_group.nickname)
      end
    end

    describe "user_group_name" do
      it "returns the user group name" do
        expect(subject.user_group_name).to eq(user_group.name)
      end
    end

    describe "membership_id" do
      it "returns the user group invitation" do
        expect(subject.membership_id).to eq(membership.id)
      end
    end

    describe "action_data" do
      it "returns the action data" do
        expect(subject.action_data).to eq(
          [
            {
              url: Decidim::Core::Engine.routes.url_helpers.group_invite_path(user_group.nickname, membership.id, format: :json),
              icon: "check-line",
              method: "patch",
              i18n_label: "decidim.group_invites.accept_invitation"
            },
            {
              url: Decidim::Core::Engine.routes.url_helpers.group_invite_path(user_group.nickname, membership.id, format: :json),
              icon: "close-circle-line",
              method: "delete",
              i18n_label: "decidim.group_invites.reject_invitation"
            }
          ]
        )
      end
    end

    describe "action_cell" do
      context "when the membership exists" do
        it "returns no cell" do
          expect(subject.action_cell).to be_nil
        end
      end

      context "when the membership is an invitation" do
        let!(:membership) { create(:user_group_membership, user:, user_group:, role: :invited) }

        it "returns the buttons cell" do
          expect(subject.action_cell).to eq("decidim/notification_actions/buttons")
        end
      end
    end
  end
end
