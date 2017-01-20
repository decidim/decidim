# -*- coding: utf-8 -*-
# frozen_string_literal: true

require "spec_helper"

describe "Admin manage user groups", type: :feature do
  let(:organization) { create(:organization) }
  let!(:user_groups) { create_list(:user_group_membership, 10, user: create(:user, organization: organization)) }

  it "verify a user group" do
    visit decidim_admin.user_groups_path

    click_button "Verify", match: :first

    within "table.user-groups tr:first" do
      expect(page).not_to have_content("Verify")
    end
  end
end