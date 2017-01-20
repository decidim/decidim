# -*- coding: utf-8 -*-
# frozen_string_literal: true

require "spec_helper"
require_relative "../shared/participatory_admin_shared_context"

describe "Admin manage user groups", type: :feature do
  include_context "participatory process admin"
  let!(:user_groups) { create_list(:user_group_membership, 10, user: create(:user, organization: organization)) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin.user_groups_path
  end

  it "verify a user group" do
    click_button "Verify", match: :first

    expect(page).not_to have_selector(".actions button", match: :first)
    
    expect(page).to have_content("verified successfully")
  end
end