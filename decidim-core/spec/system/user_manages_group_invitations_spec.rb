# frozen_string_literal: true

require "spec_helper"

describe "User manages group invitations", type: :system do
  let(:user) { create(:user, :confirmed) }
  let!(:membership) { create :user_group_membership, user: user, role: :invited }

  before do
    switch_to_host(user.organization.host)
    login_as user, scope: :user
    visit decidim.profile_groups_path(user.nickname)
  end

  context "with invitations" do
    it "allows accepting the invitation" do
      within ".list-invitation" do
        expect(page).to have_content(membership.user_group.name)
        expect(page).to have_content(membership.user_group.nickname)
      end

      click_link "Accept"

      expect(page).to have_content("Invitation accepted successfully")

      expect(page).to have_content(membership.user_group.name)
      expect(page).to have_content(membership.user_group.nickname)
    end

    it "allows rejecting the invitation" do
      within ".list-invitation" do
        expect(page).to have_content(membership.user_group.name)
        expect(page).to have_content(membership.user_group.nickname)
      end

      click_link "Reject"

      expect(page).to have_content("Invitation rejected successfully")

      expect(page).not_to have_content(membership.user_group.name)
      expect(page).not_to have_content(membership.user_group.nickname)
    end
  end
end
