# frozen_string_literal: true

require "spec_helper"

describe "User groups", type: :feature, perform_enqueued: true do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :confirmed, organization: organization) }
  let(:user_group) { create(:user_group) }

  before do
    switch_to_host(organization.host)
    create(:user_group_membership, user: user, user_group: user_group)
    login_as user, scope: :user
  end

  context "when the user group is not verified" do
    it "the user can check its status on his account page" do
      visit decidim.own_user_groups_path

      click_link "Organizations"

      expect(page).to have_content(user_group.name)
      expect(page).to have_content("Not verified")
    end
  end

  context "when the user group is not verified" do
    before do
      user_group.verify!
    end

    it "the user can check its status on his account page" do
      visit decidim.own_user_groups_path

      click_link "Organizations"

      expect(page).to have_content(user_group.name)
      expect(page).not_to have_content("Not verified")
      expect(page).to have_content("Verified")
    end
  end
end
