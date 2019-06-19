# frozen_string_literal: true

require "spec_helper"

describe "User group invite to join", type: :system do
  let!(:creator) { create(:user, :confirmed) }
  let!(:user_group) { create(:user_group, users: [creator], organization: creator.organization) }
  let!(:member) { create(:user, :confirmed, organization: creator.organization) }

  before do
    switch_to_host(user_group.organization.host)
  end

  context "when trying to access by a basic member" do
    before do
      login_as member, scope: :user
      visit decidim.profile_path(user_group.nickname)
    end

    it "does not show the link to edit" do
      expect(page).to have_no_content("Invite participant")
    end

    it "rejects the user that accesses manually" do
      visit decidim.group_invites_path(user_group.nickname)
      expect(page).to have_content("You are not authorized to perform this action")
    end
  end

  context "when trying to invite by a manager" do
    let(:invited_user) { create :user, :confirmed, organization: creator.organization }

    before do
      login_as creator, scope: :user
      visit decidim.profile_path(user_group.nickname)

      click_link "Invite participant"
    end

    it "allows inviting a user" do
      fill_in "Nickname", with: invited_user.nickname
      click_button "Invite"

      expect(page).to have_content("Participant successfully invited")
    end
  end
end
