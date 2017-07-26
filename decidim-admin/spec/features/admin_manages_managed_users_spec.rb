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

  def fill_in_the_managed_user_form
    within "form.new_managed_user" do
      fill_in :managed_user_name, with: "Foo"
      fill_in :managed_user_authorization_document_number, with: "123456789X"
      fill_in :managed_user_authorization_postal_code, with: "08224"
      page.execute_script("$('#managed_user_authorization_birthday').siblings('input:first').focus()")
    end

    page.find(".datepicker-dropdown .day", text: "12").click
    click_button "Create"
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

      fill_in_the_managed_user_form

      expect(page).to have_content("successfully")
      expect(page).to have_content("Foo")
    end
  end

  context "when the organization has more than one authorization available" do
    let(:available_authorizations) { ["Decidim::DummyAuthorizationHandler", "Decidim::DummyAuthorizationHandler"] }

    it "selects an authorization method and creates a managed user filling in the authorization info" do
      navigate_to_managed_users_page

      click_link "New"

      expect(page).to have_content(/Select an authorization method/i)
      expect(page).to have_content(/Step 1 of 2/i)

      click_link "Example authorization", match: :first

      expect(page).to have_content(/Step 2 of 2/i)

      fill_in_the_managed_user_form

      expect(page).to have_content("successfully")
      expect(page).to have_content("Foo")
    end
  end

  context "when a manager user already exists" do
    let(:available_authorizations) { ["Decidim::DummyAuthorizationHandler"] }
    let!(:managed_user) { create(:user, :managed, organization: organization) }
    let!(:authorization) { create(:authorization, user: managed_user, name: "decidim/dummy_authorization_handler", unique_id: "123456789X") }

    it "can impersonate the user filling in the correct authorization" do
      navigate_to_managed_users_page

      within find("tr", text: managed_user.name) do
        page.find("a.action-icon--impersonate").click
      end

      within "form.new_managed_user_impersonation" do
        fill_in :impersonate_managed_user_authorization_document_number, with: "123456789X"
        fill_in :impersonate_managed_user_authorization_postal_code, with: "08224"
        page.execute_script("$('#impersonate_managed_user_authorization_birthday').siblings('input:first').focus()")
      end

      page.find(".datepicker-dropdown .day", text: "12").click
      click_button "Impersonate"

      expect(page).to have_content("You are impersonating the user #{managed_user.name}")
      expect(page.current_url).to eq(decidim.root_url)
    end
  end
end
