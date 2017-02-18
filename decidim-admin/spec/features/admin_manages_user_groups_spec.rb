# -*- coding: utf-8 -*-
# frozen_string_literal: true

require "spec_helper"

describe "Admin manage user groups", type: :feature do
  include_context "participatory process admin"
  let!(:user_groups) { create_list(:user_group_membership, 10, user: create(:user, organization: organization)).map(&:user_group) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin.user_groups_path
  end

  let(:user_group) { user_groups.first }

  it "verify a user group" do
    within "tr[data-user-group-id=\"#{user_group.id}\"]" do
      click_button "Verify", match: :first
    end

    expect(page).to have_content("verified successfully")

    within "tr[data-user-group-id=\"#{user_group.id}\"]" do
      expect(page).not_to have_selector(".actions button", match: :first)
    end
  end
end
