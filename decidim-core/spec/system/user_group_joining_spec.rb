# frozen_string_literal: true

require "spec_helper"

describe "User group joining", type: :system do
  let!(:user) { create(:user, :confirmed) }
  let!(:user_group) { create(:user_group, users: [], organization: user.organization) }

  before do
    switch_to_host(user_group.organization.host)
    login_as user, scope: :user
    visit decidim.profile_path(user_group.nickname)
  end

  context "when the user already belongs to the group" do
    let!(:user_group) { create(:user_group, users: [user], organization: user.organization) }

    it "does not show the link to join" do
      expect(page).to have_no_content("Request to join group")
    end
  end

  context "when the user does not belong to the group" do
    it "allows the user to join" do
      click_link "Request to join group"

      expect(page).to have_content("Join request successfully created")
      expect(page).to have_no_content("Request to join group")
    end
  end
end
