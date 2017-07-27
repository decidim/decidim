# frozen_string_literal: true

RSpec.shared_examples "manage managed users examples" do
  include ActiveSupport::Testing::TimeHelpers

  let(:organization) { create(:organization, available_authorizations: available_authorizations) }
  let(:available_authorizations) { ["Decidim::DummyAuthorizationHandler"] }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
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

  def fill_in_the_impersonation_form
    within "form.new_managed_user_impersonation" do
      fill_in :impersonate_managed_user_authorization_document_number, with: "123456789X"
      fill_in :impersonate_managed_user_authorization_postal_code, with: "08224"
      page.execute_script("$('#impersonate_managed_user_authorization_birthday').siblings('input:first').focus()")
    end

    page.find(".datepicker-dropdown .day", text: "12").click
    click_button "Impersonate"
  end

  def impersonate_the_managed_user
    navigate_to_managed_users_page

    within find("tr", text: managed_user.name) do
      page.find("a.action-icon--impersonate").click
    end

    fill_in_the_impersonation_form
  end

  def check_impersonation_logs
    within find("tr", text: managed_user.name) do
      page.find("a.action-icon--view-logs").click
    end

    expect(page).to have_selector("tbody tr", count: 1)
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
    let!(:managed_user) { create(:user, :managed, organization: organization) }
    let!(:authorization) { create(:authorization, user: managed_user, name: "decidim/dummy_authorization_handler", unique_id: "123456789X") }

    it "can impersonate the user filling in the correct authorization" do
      impersonate_the_managed_user

      expect(page).to have_content("You are impersonating the user #{managed_user.name}")
      expect(page).to have_content("Your session will expire in #{Decidim::ImpersonationLog::SESSION_TIME_IN_MINUTES} minutes")
    end

    context "when the admin is impersonating that user" do
      before do
        impersonate_the_managed_user
      end

      it "closes the current session and check the logs" do
        visit decidim.root_path

        click_button "Close session"

        expect(page).to have_content("successfully")

        check_impersonation_logs
      end

      it "spends all the session time and is redirected automatically", perform_enqueued: true do
        travel Decidim::ImpersonationLog::SESSION_TIME_IN_MINUTES.minutes

        expect(page).to have_content("expired")

        check_impersonation_logs
      end
    end

    it "can promote the user inviting them to the application", perform_enqueued: true do
      navigate_to_managed_users_page

      within find("tr", text: managed_user.name) do
        page.find("a.action-icon--promote").click
      end

      within "form.new_managed_user_promotion" do
        fill_in :managed_user_promotion_email, with: "foo@example.org"
      end

      click_button "Promote"

      expect(page).to have_content("successfully")
      expect(page).not_to have_content("Foo")

      logout :user

      visit last_email_link

      within "form.new_user" do
        fill_in :user_password, with: "123456"
        fill_in :user_password_confirmation, with: "123456"
        find("*[type=submit]").click
      end

      expect(page).to have_content("successfully")
      expect(page).to have_content(managed_user.name)
    end
  end
end
