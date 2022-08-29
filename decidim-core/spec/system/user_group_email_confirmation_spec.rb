# frozen_string_literal: true

require "spec_helper"

describe "User group email confirmation", type: :system do
  let!(:creator) { create(:user, :confirmed) }
  let!(:user_group) { create(:user_group, users: [creator], organization: creator.organization) }

  before do
    switch_to_host(user_group.organization.host)
  end

  context "when trying to access by a basic member" do
    before do
      member = create(:user_group_membership, user_group:, role: :member).user
      login_as member, scope: :user
      visit decidim.profile_path(user_group.nickname)
    end

    it "does not show the link to edit" do
      expect(page).to have_no_content("Resend email confirmation instructions")
    end
  end

  context "when requesting by a manager" do
    before do
      login_as creator, scope: :user
      visit decidim.profile_path(user_group.nickname)
    end

    it "allows demoting a user" do
      clear_emails
      click_link "Resend email confirmation instructions"
      expect(page).to have_content("Email confirmation instructions sent")

      visit last_email_link
      expect(page).to have_content("Your email address has been successfully confirmed")
      user_group.reload
      expect(user_group).to be_confirmed
    end
  end
end
