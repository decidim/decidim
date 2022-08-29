# frozen_string_literal: true

require "spec_helper"

describe "User manages group invitations", type: :system do
  let(:user) { create(:user, :confirmed) }
  let!(:membership) { create :user_group_membership, user:, role: :invited }

  before do
    switch_to_host(user.organization.host)
    login_as user, scope: :user
    visit decidim.profile_groups_path(user.nickname)
  end

  context "with invitations" do
    it "allows accepting the invitation" do
      within ".list-invitation" do
        expect(page).to have_content(membership.user_group.name)
      end

      click_link "Accept"

      expect(page).to have_content("Invitation successfully accepted")

      expect(page).to have_content(membership.user_group.name)
    end

    it "allows rejecting the invitation" do
      within ".list-invitation" do
        expect(page).to have_content(membership.user_group.name)
      end

      click_link "Reject"

      expect(page).to have_content("Invitation successfully rejected")

      expect(page).not_to have_content(membership.user_group.name)
    end
  end
end
