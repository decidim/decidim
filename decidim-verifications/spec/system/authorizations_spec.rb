# frozen_string_literal: true

require "spec_helper"

describe "Authorizations", type: :system, with_authorization_workflows: ["dummy_authorization_handler"] do
  before do
    switch_to_host(organization.host)
  end

  context "when a new user" do
    let(:organization) { create :organization, available_authorizations: authorizations }

    let(:user) { create(:user, :confirmed, organization: organization) }

    context "when one authorization has been configured" do
      let(:authorizations) { ["dummy_authorization_handler"] }

      before do
        visit decidim.root_path
        find(".sign-in-link").click

        within "form.new_user" do
          fill_in :session_user_email, with: user.email
          fill_in :session_user_password, with: "decidim123456789"
          find("*[type=submit]").click
        end
      end

      it "redirects the user to the authorization form after the first sign in" do
        fill_in "Document number", with: "123456789X"
        page.execute_script("$('#authorization_handler_birthday').focus()")
        page.find(".datepicker-dropdown .day:not(.new)", text: "12").click

        click_button "Send"
        expect(page).to have_content("You've been successfully authorized")
      end

      it "allows the user to skip it" do
        click_link "start exploring"
        expect(page).to have_current_path decidim.account_path
        expect(page).to have_content("Participant settings")
      end

      context "and a duplicate authorization exists for a deleted user" do
        let(:document_number) { "123456789X" }
        let!(:duplicate_authorization) { create(:authorization, :granted, user: other_user, unique_id: document_number, name: authorizations.first) }
        let!(:other_user) { create(:user, :deleted, organization: user.organization) }

        it "transfers the authorization from the deleted user" do
          fill_in "Document number", with: document_number
          page.execute_script("$('#authorization_handler_birthday').focus()")
          page.find(".datepicker-dropdown .day:not(.new)", text: "12").click

          click_button "Send"
          expect(page).to have_content("You've been successfully authorized. We have recovered your old participation data based on your verification.")
        end
      end
    end

    context "when multiple authorizations have been configured", with_authorization_workflows: %w(dummy_authorization_handler dummy_authorization_workflow) do
      let(:authorizations) { %w(dummy_authorization_handler dummy_authorization_workflow) }

      before do
        visit decidim.root_path
        find(".sign-in-link").click

        within "form.new_user" do
          fill_in :session_user_email, with: user.email
          fill_in :session_user_password, with: "decidim123456789"
          find("*[type=submit]").click
        end
      end

      it "allows the user to choose which one to authorize against to" do
        expect(page).to have_css("a.button.expanded", count: 2)
      end
    end
  end

  context "when existing user from their account" do
    let(:organization) { create :organization, available_authorizations: authorizations }
    let(:user) { create(:user, :confirmed, organization: organization) }

    before do
      login_as user, scope: :user
      visit decidim.root_path
    end

    context "when user has not already been authorized" do
      let(:authorizations) { ["dummy_authorization_handler"] }

      it "allows the user to authorize against available authorizations" do
        within_user_menu do
          click_link "My account"
        end

        click_link "Authorizations"
        click_link "Example authorization"

        fill_in "Document number", with: "123456789X"
        page.execute_script("$('#authorization_handler_birthday').focus()")
        page.find(".datepicker-dropdown .datepicker-days", text: "12").click
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

      it "checks if the given data is invalid" do
        within_user_menu do
          click_link "My account"
        end

        click_link "Authorizations"
        click_link "Example authorization"

        fill_in "Document number", with: "12345678"
        page.execute_script("$('#authorization_handler_birthday').focus()")
        page.find(".datepicker-dropdown .datepicker-days", text: "12").click
        click_button "Send"

        expect(page).to have_content("There was a problem creating the authorization.")
      end
    end

    context "when the user has already been authorized" do
      let(:authorizations) { ["dummy_authorization_handler"] }

      let!(:authorization) do
        create(:authorization, name: "dummy_authorization_handler", user: user)
      end

      it "shows the authorization at their account" do
        within_user_menu do
          click_link "My account"
        end

        click_link "Authorizations"

        within ".authorizations-list" do
          expect(page).to have_content("Example authorization")
        end
      end

      context "when the authorization is renewable" do
        describe "and still not over the waiting period" do
          let!(:authorization) do
            create(:authorization, name: "dummy_authorization_handler", user: user, granted_at: 1.minute.ago)
          end

          it "can't be renewed yet" do
            within_user_menu do
              click_link "My account"
            end

            click_link "Authorizations"

            within ".authorizations-list" do
              expect(page).to have_no_link("Example authorization")
              expect(page).to have_no_css(".authorization-renewable")
            end
          end
        end

        describe "and passed the time between renewals" do
          let!(:authorization) do
            create(:authorization, name: "dummy_authorization_handler", user: user, granted_at: 6.minutes.ago)
          end

          it "can be renewed" do
            within_user_menu do
              click_link "My account"
            end

            click_link "Authorizations"

            within ".authorizations-list" do
              expect(page).to have_link("Example authorization")
              expect(page).to have_css(".authorization-renewable")
            end
          end

          it "shows a modal with renew information" do
            within_user_menu do
              click_link "My account"
            end

            click_link "Authorizations"
            click_link "Example authorization"

            within "#renew-modal" do
              expect(page).to have_content("Example authorization")
              expect(page).to have_content("This is the data of the current verification:")
              expect(page).to have_content("Continue")
              expect(page).to have_content("Cancel")
            end
          end

          describe "and clicks on the button to renew" do
            it "shows the verification form to start again" do
              within_user_menu do
                click_link "My account"
              end
              click_link "Authorizations"
              click_link "Example authorization"
              within "#renew-modal" do
                click_link "Continue"
              end

              expect(page).to have_content("Document number")
              expect(page).to have_button "Send"
            end
          end
        end
      end

      context "when the authorization has not expired yet" do
        let!(:authorization) do
          create(:authorization, name: "dummy_authorization_handler", user: user, granted_at: 2.seconds.ago)
        end

        it "can't be renewed yet" do
          within_user_menu do
            click_link "My account"
          end

          click_link "Authorizations"

          within ".authorizations-list" do
            expect(page).to have_no_link("Example authorization")
            expect(page).to have_content(I18n.l(authorization.granted_at, format: :long))
          end
        end
      end

      context "when the authorization has expired" do
        let!(:authorization) do
          create(:authorization, name: "dummy_authorization_handler", user: user, granted_at: 2.months.ago)
        end

        it "can be renewed" do
          within_user_menu do
            click_link "My account"
          end

          click_link "Authorizations"

          within ".authorizations-list" do
            expect(page).to have_link("Example authorization")
            click_link "Example authorization"
          end

          within "#renew-modal" do
            click_link "Continue"
          end

          fill_in "Document number", with: "123456789X"
          click_button "Send"

          expect(page).to have_content("You've been successfully authorized")
        end
      end
    end

    context "when no authorizations are configured", with_authorization_handlers: [] do
      let(:authorizations) { [] }

      it "doesn't list authorizations" do
        click_link user.name
        expect(page).to have_no_content("Authorizations")
      end
    end
  end
end
