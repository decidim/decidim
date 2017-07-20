# frozen_string_literal: true

require "spec_helper"

describe "Admin manages managed users", type: :feature do
  let(:organization) { create(:organization, available_authorizations: available_authorizations) }
  let(:user) { create(:user, :admin, :confirmed, organization: organization) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  def navigate_to_managed_users_page
    visit decidim_admin.root_path
    click_link "Users"
    click_link "Managed users"
  end

  context "when the organization doesn't have any authorization available" do
    let(:available_authorizations) { [] }

    it "the managed users page displays a warning and creation is disabled" do
      navigate_to_managed_users_page

      expect(page).to have_selector("a.button.disabled", text: "NEW")
      expect(page).to have_content("You need at least one authorization enabled for this organization.")
    end
  end
end
