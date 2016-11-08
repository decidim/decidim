# frozen_string_literal: true
require "spec_helper"

describe "Authorizations", type: :feature, perform_enqueued: true do
  let(:organization) { user.organization }

  before do
    switch_to_host(organization.host)
  end

  context "a new user" do
    let(:user) { create(:user, :confirmed) }

    context "when one authorization has been configured" do
      before do
        Decidim.authorization_handlers = [Decidim::DummyAuthorizationHandler]
        visit decidim.root_path
        find(".sign-in-link").click
        fill_in :user_email, with: user.email
        fill_in :user_password, with: "password1234"
        find("*[type=submit]").click
      end

      it "redirects the user to the authorization form after the first sign in" do
        fill_in "Document number", with: "123456789X"
        fill_in "Birthday", with: "01/01/1970"
        click_button "Send"
        expect(page).to have_content("You've been successfully authorized")
      end

      it "allows the user to skip it" do
        find(".skip a").click
        expect(page).to have_content("processes")
      end
    end

    context "when multiple authorizations have been configured" do
      before do
        Decidim.authorization_handlers = [
          Decidim::DummyAuthorizationHandler,
          Decidim::DummyAuthorizationHandler
        ]

        visit decidim.root_path
        find(".sign-in-link").click
        fill_in :user_email, with: user.email
        fill_in :user_password, with: "password1234"
        find("*[type=submit]").click
      end

      it "allows the user to choose which one to authorize against to" do
        expect(page).to have_css("a.button.expanded", count: 2)
      end
    end
  end

  context "user account" do
    let(:user) { create(:user, :confirmed) }

    before do
      login_as user, scope: :user
      visit decidim.root_path
    end

    it "allows the user to authorize against available authorizations" do
      within_user_menu do
        click_link "My account"
      end

      click_link "Authorizations"
      click_link "Example authorization"

      fill_in "Document number", with: "123456789X"
      fill_in "Birthday", with: "01/01/1970"
      click_button "Send"

      expect(page).to have_content("You've been successfully authorized")

      within "#user-settings-tabs" do
        click_link "Authorizations"
      end

      within "#authorizations" do
        expect(page).to have_content("Example authorization")
        expect(page).to_not have_link("Example authorization")
      end
    end

    context "when the user has already been authorised" do
      let!(:authorization) do
        create(:authorization,
               name: Decidim::DummyAuthorizationHandler.handler_name,
               user: user
              )
      end

      it "shows the authorization at their account" do
        within_user_menu do
          click_link "My account"
        end

        click_link "Authorizations"

        within "#authorizations" do
          expect(page).to have_content("Example authorization")
          expect(page).to_not have_link("Example authorization")
          expect(page).to have_content(I18n.localize(authorization.created_at, format: :long))
        end
      end

      it "allows the user to delete an authorization" do
        within_user_menu do
          click_link "My account"
        end

        click_link "Authorizations"

        within "#authorizations" do
          click_icon "circle-x"
        end

        expect(page).to have_content("Authorization successfully destroyed")

        click_link "Authorizations"

        within "#authorizations" do
          expect(page).to have_link("Example authorization")
        end
      end
    end

    context "when no authorizations are configured" do
      before do
        Decidim.authorization_handlers = []
      end

      it "doesn't list authorizations" do
        click_link user.name
        expect(page).to_not have_content("Authorizations")
      end
    end
  end
end
