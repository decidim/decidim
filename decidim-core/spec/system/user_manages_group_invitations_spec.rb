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
    let!(:notification) { create(:notification, user:, event_class: "Decidim::InvitedToGroupEvent", extra:) }
    let(:extra) do
      {
        "received_as" => "affected_user",
        "user_group_nickname" => membership.user_group.nickname,
        "user_group_name" => membership.user_group.name,
        "membership_id" => membership.id
      }
    end

    before do
      visit decidim.notifications_path
    end

    it "allows accepting the invitation" do
      within "#notifications" do
        click_on "Accept"
        expect(page).to have_content("Invitation successfully accepted")
        visit decidim.notifications_path
        expect(page).to have_no_content("Invitation successfully accepted")
      end
    end

    it "allows rejecting the invitation" do
      within "#notifications" do
        click_on "Reject"
        expect(page).to have_content("Invitation successfully rejected")
        visit decidim.notifications_path
        expect(page).to have_no_content("Invitation successfully rejected")
      end
    end

    context "and invitation has already been accepted" do
      let!(:membership) { create(:user_group_membership, role: :member) }

      it "does not show the invitation" do
        within "#notifications" do
          expect(page).to have_no_content("Accept")
          expect(page).to have_no_content("Reject")
        end
      end
    end
  end
end
