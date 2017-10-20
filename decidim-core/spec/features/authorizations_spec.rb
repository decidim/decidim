# frozen_string_literal: true

require "spec_helper"

describe "Authorizations", type: :feature, perform_enqueued: true do
  before do
    switch_to_host(organization.host)
  end

  context "a new user" do
    let(:organization) { create :organization, available_authorizations: authorizations }

    let(:user) { create(:user, :confirmed, organization: organization) }

    context "when one authorization has been configured" do
      let(:authorizations) { ["Decidim::DummyAuthorizationHandler"] }

      before do
        visit decidim.root_path
        find(".sign-in-link").click

        within "form.new_user" do
          fill_in :user_email, with: user.email
          fill_in :user_password, with: "password1234"
          find("*[type=submit]").click
        end
      end

      it "redirects the user to the authorization form after the first sign in" do
        fill_in "Document number", with: "123456789X"
        page.execute_script("$('#date_field_authorization_handler_birthday').focus()")
        page.find(".datepicker-dropdown .day", text: "12").click

        click_button "Send"
        expect(page).to have_content("You've been successfully authorized")
      end

      it "allows the user to skip it" do
        click_link "start exploring"
        expect(current_path).to eq decidim.account_path
      end
    end

    context "when multiple authorizations have been configured" do
      let(:authorizations) { ["Decidim::DummyAuthorizationHandler", "Decidim::DummyAuthorizationHandler"] }

      before do
        visit decidim.root_path
        find(".sign-in-link").click

        within "form.new_user" do
          fill_in :user_email, with: user.email
          fill_in :user_password, with: "password1234"
          find("*[type=submit]").click
        end
      end

      it "allows the user to choose which one to authorize against to" do
        expect(page).to have_css("a.button.expanded", count: 2)
      end
    end
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

    context "when no authorizations are configured", without_authorizations: true do
      let(:authorizations) { [] }

      it "doesn't list authorizations" do
        click_link user.name
        expect(page).to have_no_content("Authorizations")
      end
    end
  end
end
