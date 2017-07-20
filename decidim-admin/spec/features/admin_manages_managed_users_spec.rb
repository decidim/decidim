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

  context "when the organization has one authorization available" do
    let(:available_authorizations) { ["Decidim::DummyAuthorizationHandler"] }

    it "creates a managed user filling in the authorization info" do
      navigate_to_managed_users_page

      click_link "New"

      within "form.new_managed_user" do
        fill_in :managed_user_name, with: "Foo"
        fill_in :managed_user_authorization_document_number, with: "123456789X"
        fill_in :managed_user_authorization_postal_code, with: "08224"
        page.execute_script("$('#managed_user_authorization_birthday').siblings('input:first').focus()")
      end

      page.find(".datepicker-dropdown .day", text: "12").click
      click_button "Create"

      expect(page).to have_content("successfully")
      expect(page).to have_content("Foo")
    end
  end
end
