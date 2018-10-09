# frozen_string_literal: true

require "spec_helper"

describe "Profile", type: :system do
  let(:user) { create(:user, :confirmed) }
  let(:user_group) { create(:user_group, users: [user], organization: user.organization) }

  before do
    switch_to_host(user_group.organization.host)
    visit decidim.profile_path(user_group.nickname)
  end

  it "shows user group name in the header and its nickname" do
    expect(page).to have_selector("h5", text: user_group.name)
    expect(page).to have_content(user_group.nickname)
  end

  it "does not show verification stuff" do
    expect(page).to have_no_content("This user group is publicly verified")
  end

  context "and user group is verified" do
    let(:user_group) do
      create(:user_group, :verified, users: [user], organization: user.organization)
    end

    it "shows officialization status" do
      expect(page).to have_content("This user group is publicly verified")
    end
  end

  context "when displaying followers" do
    let(:other_user) { create(:user, organization: user_group.organization) }

    before do
      create(:follow, user: other_user, followable: user_group)
      visit decidim.profile_path(user_group.nickname)
    end

    it "shows the number of followers and following" do
      expect(page).to have_link("Followers 1")
      expect(page).to have_link("Follows 0")
    end

    it "lists the followers" do
      click_link "Followers"

      expect(page).to have_content(other_user.name)
    end
  end

  context "when displaying members" do
    it "lists the members" do
      click_link "Members"

      expect(page).to have_content(user.name)
    end
  end
end
