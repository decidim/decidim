# frozen_string_literal: true

require "spec_helper"

describe "User group profile edition", type: :system do
  let!(:creator) { create(:user, :confirmed) }
  let!(:user_group) { create(:user_group, users: [creator], organization: creator.organization) }
  let!(:member) { create(:user, :confirmed, organization: creator.organization) }

  before do
    create :user_group_membership, user: member, user_group: user_group, role: :member

    switch_to_host(user_group.organization.host)
  end

  context "when trying to access by a basic member" do
    before do
      login_as member, scope: :user
      visit decidim.profile_path(user_group.nickname)
    end

    it "does not show the link to edit" do
      expect(page).to have_no_content("Manage members")
    end

    it "rejects the user that accesses manually" do
      visit decidim.edit_group_path(user_group.nickname)
      expect(page).to have_content("You are not authorized to perform this action")
    end
  end

  context "when trying to edit by a manager" do
    let(:requested_user) { create :user, :confirmed, organization: creator.organization }
    let!(:membership) { create :user_group_membership, user: requested_user, user_group: user_group, role: :requested }

    before do
      login_as creator, scope: :user
      visit decidim.profile_path(user_group.nickname)

      click_link "Manage members"
    end

    it "allows managing the group members" do
      expect(page).to have_content("Current members (without admins)")
      expect(page).to have_content(member.name)
    end

    context "with pending requests" do
      it "lists the pending requests" do
        within ".list-request" do
          expect(page).to have_content("The following users have applied to join this group")
          expect(page).to have_content(requested_user.name)
        end
      end

      it "allows accepting a join request" do
        within ".list-request" do
          expect(page).to have_content(requested_user.name)
          click_link "Accept"
        end

        expect(page).to have_no_css(".list-request")
        expect(page).to have_content("Join request accepted successfully")
      end

      it "allows rejecting a join request" do
        within ".list-request" do
          expect(page).to have_content(requested_user.name)
          click_link "Reject"
        end

        expect(page).to have_no_css(".list-request")
        expect(page).to have_content("Join request rejected successfully")
      end
    end
  end
end
