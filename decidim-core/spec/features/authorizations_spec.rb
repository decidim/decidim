# frozen_string_literal: true

require "spec_helper"

describe "Authorizations", type: :feature, perform_enqueued: true do
  before do
    switch_to_host(organization.host)
  end

  context "user account" do
    let(:organization) { create :organization, available_authorizations: authorizations }
    let(:user) { create(:user, :confirmed) }

    before do
      login_as user, scope: :user
      visit decidim.root_path
    end

    context "when user has not already been authorized" do
      let(:authorizations) { ["Decidim::DummyAuthorizationHandler"] }

      it "allows the user to authorize against available authorizations" do
        within_user_menu do
          click_link "My account"
        end

        click_link "Authorizations"
        click_link "Example authorization"

        fill_in "Document number", with: "123456789X"
        page.execute_script("$('#date_field_authorization_handler_birthday').focus()")
        page.find(".datepicker-dropdown .day", text: "12").click
        click_button "Send"

        expect(page).to have_content("You've been successfully authorized")

        within "#user-settings-tabs" do
          click_link "Authorizations"
        end

        within ".authorizations-list" do
          expect(page).to have_content("Example authorization")
          expect(page).to have_no_link("Example authorization")
        end
      end
    end

    context "when the user has already been authorised" do
      let(:authorizations) { ["Decidim::DummyAuthorizationHandler"] }

      let!(:authorization) do
        create(:authorization,
               name: Decidim::DummyAuthorizationHandler.handler_name,
               user: user)
      end

      it "shows the authorization at their account" do
        within_user_menu do
          click_link "My account"
        end

        click_link "Authorizations"

        within ".authorizations-list" do
          expect(page).to have_content("Example authorization")
          expect(page).to have_no_link("Example authorization")
          expect(page).to have_content(I18n.localize(authorization.created_at, format: :long))
        end
      end
    end

    context "when no authorizations are configured" do
      let(:authorizations) { [] }

      before do
        Decidim.authorization_handlers = []
      end

      it "doesn't list authorizations" do
        click_link user.name
        expect(page).to have_no_content("Authorizations")
      end
    end
  end
end
