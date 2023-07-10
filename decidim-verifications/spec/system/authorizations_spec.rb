# frozen_string_literal: true

require "spec_helper"

describe "Authorizations", type: :system, with_authorization_workflows: ["dummy_authorization_handler"] do
  before do
    switch_to_host(organization.host)
  end

  context "when a new user" do
    let(:organization) { create(:organization, available_authorizations: authorizations) }

    let(:user) { create(:user, :confirmed, organization:) }

    context "when one authorization has been configured" do
      let(:authorizations) { ["dummy_authorization_handler"] }

      before do
        visit decidim.root_path
        within "#main-bar" do
          click_link("Sign In")
        end

        within "form.new_user", match: :first do
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
        expect(page).to have_content("You have been successfully authorized")
      end

      it "allows the user to skip it" do
        click_link "start exploring"
        expect(page).to have_current_path decidim.account_path

        # REDESIGN_PENDING: This page is not redesigned
        expect(page).to have_content("Participant settings") unless Decidim.redesign_active
      end

      context "and a duplicate authorization exists for an existing user" do
        let(:document_number) { "123456789X" }
        let!(:duplicate_authorization) { create(:authorization, :granted, user: other_user, unique_id: document_number, name: authorizations.first) }
        let!(:other_user) { create(:user, :confirmed, organization: user.organization) }

        it "transfers the authorization from the deleted user" do
          fill_in "Document number", with: document_number
          page.execute_script("$('#authorization_handler_birthday').focus()")
          page.find(".datepicker-dropdown .day:not(.new)", text: "12").click

          expect { click_button "Send" }.not_to change(Decidim::Authorization, :count)
          expect(page).to have_content("There was a problem creating the authorization.")
          expect(page).to have_content("A participant is already authorized with the same data. An administrator will contact you to verify your details.")

          expect { click_button "Send" }.not_to change(Decidim::AuthorizationTransfer, :count)
          expect(page).to have_content("There was a problem creating the authorization.")
        end
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
          expect(page).to have_content("You have been successfully authorized.")
          expect(page).not_to have_content("We have recovered the following participation data based on your authorization:")
        end

        context "and the deleted user for the duplicate authorization had transferrable data" do
          let(:commentable) do
            create(
              :dummy_resource,
              component: create(:component, manifest_name: "dummy", organization: user.organization)
            )
          end

          before do
            create_list(:comment, 10, author: other_user, commentable:)
            create_list(:proposal, 5, users: [other_user], component: create(:proposal_component, organization: user.organization))

            within_user_menu do
              click_link "My account"
            end

            # REDESIGN_PENDING - My account is not redesigned yet and does not
            # contain an "Authorizations" link. Uncomment after redesigning it
            # and remove the visit_authorizations call
            # click_link "Authorizations"

            visit_authorizations

            click_link "Example authorization"
          end

          it "reports the transferred participation data" do
            fill_in "Document number", with: document_number
            page.execute_script("$('#authorization_handler_birthday').focus()")
            page.find(".datepicker-dropdown .day:not(.new)", text: "12").click

            click_button "Send"
            expect(page).to have_content("You have been successfully authorized.")
            expect(page).to have_content("We have recovered the following participation data based on your authorization:")
            expect(page).to have_content("Comments: 10")
            expect(page).to have_content("Proposals: 5")
          end
        end
      end
    end

    context "when multiple authorizations have been configured", with_authorization_workflows: %w(dummy_authorization_handler dummy_authorization_workflow) do
      let(:authorizations) { %w(dummy_authorization_handler dummy_authorization_workflow) }

      before do
        visit decidim.root_path
        within "#main-bar" do
          click_link("Sign In")
        end

        within "form.new_user", match: :first do
          fill_in :session_user_email, with: user.email
          fill_in :session_user_password, with: "decidim123456789"
          find("*[type=submit]").click
        end
      end

      it "allows the user to choose which one to authorize against to" do
        expect(page).to have_css("a[href]", text: /\AVerify against /, count: 2)
      end
    end
  end

  context "when existing user from their account" do
    let(:organization) { create(:organization, available_authorizations: authorizations) }
    let(:user) { create(:user, :confirmed, organization:) }

    before do
      login_as user, scope: :user
      visit decidim.root_path
    end

    context "when user has not already been authorized" do
      let(:authorizations) { ["dummy_authorization_handler"] }

      it "allows the user to authorize against available authorizations" do
        visit_authorizations
        click_link(text: /Example authorization/)

        fill_in "Document number", with: "123456789X"
        # REDESIGN_PENDING: The datepicker interaction fails with the redesign
        # and the click_button "Send" action does not submit the form. The
        # datepicker component redesign is pending.
        # page.execute_script("$('#authorization_handler_birthday').focus()")
        # page.find(".datepicker-dropdown .datepicker-days", text: "12").click
        click_button "Send"

        expect(page).to have_content("You have been successfully authorized")

        visit_authorizations

        within ".authorizations-list" do
          expect(page).to have_content("Example authorization")
          expect(page).not_to have_link(text: /Example authorization/)
        end
      end

      it "checks if the given data is invalid" do
        visit_authorizations
        click_link(text: /Example authorization/)

        fill_in "Document number", with: "12345678"
        # REDESIGN_PENDING: The datepicker interaction fails with the redesign
        # and the click_button "Send" action does not submit the form. The
        # datepicker component redesign is pending.
        # page.execute_script("$('#authorization_handler_birthday').focus()")
        # page.find(".datepicker-dropdown .datepicker-days", text: "12").click
        click_button "Send"

        expect(page).to have_content("There was a problem creating the authorization.")
      end
    end

    context "when the user has already been authorized" do
      let(:authorizations) { ["dummy_authorization_handler"] }

      let!(:authorization) do
        create(:authorization, name: "dummy_authorization_handler", user:)
      end

      it "shows the authorization at their account" do
        visit_authorizations

        within ".authorizations-list" do
          expect(page).to have_content("Example authorization")
        end
      end

      context "when the authorization is renewable" do
        describe "and still not over the waiting period" do
          let!(:authorization) do
            create(:authorization, name: "dummy_authorization_handler", user:, granted_at: 1.minute.ago)
          end

          it "cannot be renewed yet" do
            visit_authorizations

            within ".authorizations-list" do
              expect(page).not_to have_link(text: /Example authorization/)
              expect(page).not_to have_css(".authorization-renewable")
            end
          end
        end

        describe "and passed the time between renewals" do
          let!(:authorization) do
            create(:authorization, name: "dummy_authorization_handler", user:, granted_at: 6.minutes.ago)
          end

          it "can be renewed" do
            visit_authorizations

            within ".authorizations-list" do
              expect(page).to have_css("div[data-dialog-open='renew-modal']", text: /Example authorization/)
            end
          end

          it "shows a modal with renew information" do
            skip_unless_redesign_enabled("This test pass using redesigned modals")

            visit_authorizations
            page.find("div[data-dialog-open='renew-modal']", text: /Example authorization/).click

            within "#renew-modal" do
              expect(page).to have_content("Example authorization")
              expect(page).to have_content("This is the data of the current verification:")
              expect(page).to have_content("Continue")
              expect(page).to have_content("Cancel")
            end
          end

          describe "and clicks on the button to renew" do
            it "shows the verification form to start again" do
              skip_unless_redesign_enabled("This test pass using redesigned modals")

              visit_authorizations
              page.find("div[data-dialog-open='renew-modal']", text: /Example authorization/).click
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
          create(:authorization, name: "dummy_authorization_handler", user:, granted_at: 2.seconds.ago)
        end

        it "cannot be renewed yet" do
          visit_authorizations

          within ".authorizations-list" do
            expect(page).not_to have_link(text: /Example authorization/)
            expect(page).to have_content(I18n.l(authorization.granted_at, format: :long_with_particles))
          end
        end
      end

      context "when the authorization has expired" do
        let!(:authorization) do
          create(:authorization, name: "dummy_authorization_handler", user:, granted_at: 2.months.ago)
        end

        it "can be renewed" do
          skip_unless_redesign_enabled("This test pass using redesigned modals")

          visit_authorizations

          within ".authorizations-list" do
            expect(page).to have_css("[data-verification]", text: /Example authorization/)
            page.find("[data-verification]", text: /Example authorization/).click
          end

          within "#renew-modal" do
            click_link "Continue"
          end

          fill_in "Document number", with: "123456789X"
          click_button "Send"

          expect(page).to have_content("You have been successfully authorized")
        end
      end
    end

    context "when no authorizations are configured", with_authorization_handlers: [] do
      let(:authorizations) { [] }

      it "does not list authorizations" do
        visit decidim_verifications.authorizations_path
        expect(page).not_to have_link("Authorizations")
      end
    end
  end

  private

  def visit_authorizations
    if Decidim.redesign_active
      visit decidim_verifications.authorizations_path
    else
      within_user_menu do
        click_link "My account"
      end

      click_link "Authorizations"
    end
  end
end
