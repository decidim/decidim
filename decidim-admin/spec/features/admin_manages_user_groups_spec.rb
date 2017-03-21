# -*- coding: utf-8 -*-
# frozen_string_literal: true

require "spec_helper"

describe "Admin manage user groups", type: :feature do
  include_context "participatory process admin"
  let!(:user_groups) { create_list(:user_group, 10, users: [create(:user, organization: organization)]) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin.user_groups_path
  end

  let(:user_group) { user_groups.first }

  it "verifies a user group" do
    within "tr[data-user-group-id=\"#{user_group.id}\"]" do
      click_link "Verify", match: :first
    end

    expect(page).to have_content("verified successfully")

    within "tr[data-user-group-id=\"#{user_group.id}\"]" do
      expect(page).to have_no_selector(".actions button", match: :first)
    end
  end
end
