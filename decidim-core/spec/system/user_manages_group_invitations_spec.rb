# frozen_string_literal: true

require "spec_helper"

describe "User manages group invitations" do
  let(:user) { membership.user }
  let!(:membership) { create(:user_group_membership, role: :invited) }

  before do
    switch_to_host(user.organization.host)
    login_as user, scope: :user
  end

  context "when using the group page" do
    before do
      visit decidim.profile_groups_path(user.nickname)
    end

    it "allows accepting the invitation" do
      within "#list-invitation" do
        expect(page).to have_content(membership.user_group.name)
      end

      click_on "Accept"

      expect(page).to have_content("Invitation successfully accepted")

      expect(page).to have_content(membership.user_group.name)
    end

    it "allows rejecting the invitation" do
      within "#list-invitation" do
        expect(page).to have_content(membership.user_group.name)
      end

      click_on "Reject"

      expect(page).to have_content("Invitation successfully rejected")

      expect(page).to have_no_content(membership.user_group.name)
    end
  end

  context "when using the notifications page" do
    let!(:notification) { create(:notification, user:, extra:) }
    let(:extra) do
      {
        "received_as" => "affected_user",
        "user_group_nickname" => membership.user_group.nickname,
        "user_group_name" => membership.user_group.name,
        "membership_id" => membership.id,
        "action" => action
      }
    end
    let(:action) do
      {
        "type" => "buttons",
        "data" => [
          {
            url: decidim.group_invite_path(membership.user_group, membership.id),
            icon: "check-line",
            method: "patch",
            i18n_label: "decidim.group_invites.accept_invitation"
          },
          {
            url: decidim.group_invite_path(membership.user_group, membership.id),
            icon: "close-circle-line",
            method: "delete",
            i18n_label: "decidim.group_invites.reject_invitation"
          }
        ]
      }
    end

    before do
      visit decidim.notifications_path
    end

    it "allows accepting the invitation" do
      within "#notifications" do
        click_on "Accept"
        expect(page).to have_content("Invitation successfully accepted")
      end
    end

    it "allows rejecting the invitation" do
      within "#notifications" do
        click_on "Reject"
        expect(page).to have_content("Invitation successfully rejected")
      end
    end
  end
end
