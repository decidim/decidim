# frozen_string_literal: true

require "spec_helper"

describe "Admin manages user groups", type: :feature do
  let(:organization) { create(:organization) }

  let!(:user) { create(:user, :admin, :confirmed, organization: organization) }

  let!(:user_groups) { create_list(:user_group, 3, users: [create(:user, organization: organization)]) }

  let(:user_group) { user_groups.first }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin.root_path
    click_link "Users"
    click_link "User groups"
  end

  it "verifies a user group" do
    within "tr[data-user-group-id=\"#{user_group.id}\"]" do
      click_link "Verify"
    end

    expect(page).to have_content("verified successfully")

    within "tr[data-user-group-id=\"#{user_group.id}\"]" do
      expect(page).to have_content("Verified")
    end
  end

  it "reject a user group" do
    within "tr[data-user-group-id=\"#{user_group.id}\"]" do
      click_link "Reject"
    end

    expect(page).to have_content("rejected successfully")

    within "tr[data-user-group-id=\"#{user_group.id}\"]" do
      expect(page).to have_content("Rejected")
    end
  end
end
