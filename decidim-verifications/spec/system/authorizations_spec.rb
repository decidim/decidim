# frozen_string_literal: true

require "spec_helper"

describe "Authorizations", with_authorization_workflows: %w(dummy_authorization_handler another_dummy_authorization_handler) do
  before do
    switch_to_host(organization.host)
  end

  context "when a new user visits authorizations" do
    let(:organization) { create(:organization, available_authorizations: authorizations) }

    let(:user) { create(:user, :confirmed, organization:) }

    context "when one authorization has been configured" do
      let(:authorizations) { %w(dummy_authorization_handler another_dummy_authorization_handler) }
      let!(:homepage_content_block) { create(:content_block, organization:, scope_name: :homepage, manifest_name: :how_to_participate) }

      before do
        sign_in
        visit_authorizations
      end

      it "shows one authorization link" do
        expect(page).to have_css("a[data-verification]", text: "Example authorization")
      end

      it "allows the user to fill in the authorization form" do
        click_on "Example authorization"

        fill_in "Document number", with: "123456789X"

        fill_in_datepicker :authorization_handler_birthday_date, with: Time.current.change(day: 12).strftime("%d/%m/%Y")

        click_on "Send"
        expect(page).to have_content("You have been successfully authorized")
      end

      it "allows the user to skip it" do
        click_on "Example authorization"

        click_on "start exploring"
        expect(page).to have_current_path decidim.root_path

        expect(page).to have_content("How do I take part in a process?")
      end

      context "and a duplicate authorization exists for an existing user" do
        let(:document_number) { "123456789X" }
        let!(:duplicate_authorization) { create(:authorization, :granted, user: other_user, unique_id: document_number, name: authorizations.first) }
        let!(:other_user) { create(:user, :confirmed, organization: user.organization) }

        it "transfers the authorization from the deleted user" do
          click_on "Example authorization"

          fill_in "Document number", with: document_number

          fill_in_datepicker :authorization_handler_birthday_date, with: Time.current.change(day: 12).strftime("%d/%m/%Y")

          expect { click_on "Send" }.not_to change(Decidim::Authorization, :count)
          expect(page).to have_content("There was a problem creating the authorization.")
          expect(page).to have_content("A participant is already authorized with the same data. An administrator will contact you to verify your details.")

          expect { click_on "Send" }.not_to change(Decidim::AuthorizationTransfer, :count)
          expect(page).to have_content("There was a problem creating the authorization.")
        end
      end

      context "and a duplicate authorization exists for a deleted user" do
        let(:document_number) { "123456789X" }
        let!(:duplicate_authorization) { create(:authorization, :granted, user: other_user, unique_id: document_number, name: authorizations.first) }
        let!(:other_user) { create(:user, :deleted, organization: user.organization) }

        it "transfers the authorization from the deleted user" do
          click_on "Example authorization"

          fill_in "Document number", with: document_number

          fill_in_datepicker :authorization_handler_birthday_date, with: Time.current.change(day: 12).strftime("%d/%m/%Y")

          click_on "Send"
          expect(page).to have_content("You have been successfully authorized.")
          expect(page).to have_no_content("We have recovered the following participation data based on your authorization:")
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

            visit_authorizations

            click_on "Example authorization"
          end

          it "reports the transferred participation data" do
            fill_in "Document number", with: document_number

            fill_in_datepicker :authorization_handler_birthday_date, with: Time.current.change(day: 12).strftime("%d/%m/%Y")

            click_on "Send"
            expect(page).to have_content("You have been successfully authorized.")
            expect(page).to have_content("We have recovered the following participation data based on your authorization:")
            expect(page).to have_content("Comments: 10")
            expect(page).to have_content("Proposals: 5")
          end
        end
      end
    end

    context "when multiple authorizations have been configured", with_authorization_workflows: %w(dummy_authorization_handler another_dummy_authorization_handler) do
      let(:authorizations) { %w(dummy_authorization_handler another_dummy_authorization_handler) }

      before do
        sign_in
        visit_authorizations
      end

      it "allows the user to choose which one to authorize against to" do
        expect(page).to have_css("a[data-verification]", count: 2)
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
      let(:authorizations) { %w(dummy_authorization_handler another_dummy_authorization_handler) }

      it "allows the user to authorize against available authorizations" do
        visit_authorizations
        click_on(text: /Example authorization/)

        fill_in "Document number", with: "123456789X"
        fill_in_datepicker :authorization_handler_birthday_date, with: Time.current.change(day: 12).strftime("%d/%m/%Y")

        click_on "Send"

        expect(page).to have_content("You have been successfully authorized")

        visit_authorizations

        within ".authorizations-list" do
          expect(page).to have_content("Example authorization")
          expect(page).to have_no_link(text: /Example authorization/)
        end
      end

      it "checks if the given data is invalid" do
        visit_authorizations
        click_on(text: /Example authorization/)

        fill_in "Document number", with: "12345678"
        fill_in_datepicker :authorization_handler_birthday_date, with: Time.current.change(day: 12).strftime("%d/%m/%Y")

        click_on "Send"

        expect(page).to have_content("There was a problem creating the authorization.")
      end
    end

    context "when the user has already been authorized" do
      let(:authorizations) { %w(dummy_authorization_handler another_dummy_authorization_handler) }

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
              expect(page).to have_no_link(text: /Example authorization/)
              expect(page).to have_no_css(".authorization-renewable")
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
              visit_authorizations
              page.find("div[data-dialog-open='renew-modal']", text: /Example authorization/).click
              within "#renew-modal" do
                click_on "Continue"
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
            expect(page).to have_no_link(text: /Example authorization/)
            expect(page).to have_content(I18n.l(authorization.granted_at, format: :long_with_particles))
          end
        end
      end

      context "when the authorization has expired" do
        let!(:authorization) do
          create(:authorization, name: "dummy_authorization_handler", user:, granted_at: 2.months.ago)
        end

        it "can be renewed" do
          visit_authorizations

          within ".authorizations-list" do
            expect(page).to have_css("[data-verification]", text: /Example authorization/)
            page.find("[data-verification]", text: /Example authorization/).click
          end

          within "#renew-modal" do
            click_on "Continue"
          end

          fill_in "Document number", with: "123456789X"
          click_on "Send"

          expect(page).to have_content("You have been successfully authorized")
        end
      end
    end

    context "when no authorizations are configured", with_authorization_handlers: [] do
      let(:authorizations) { [] }

      it "does not list authorizations" do
        visit decidim_verifications.authorizations_path
        expect(page).to have_no_link("Authorizations")
      end
    end
  end

  context "when there is onboarding action data and the user signs in" do
    let(:organization) { create(:organization, available_authorizations: authorizations) }
    let(:component) { create(:component, manifest_name: "dummy", organization:, permissions:) }
    let(:commentable) { create(:dummy_resource, component:) }
    let(:permissions) { nil }
    let(:comment) { create(:comment, commentable:) }
    let(:action) { :comment }
    let(:extended_data) { { onboarding: { action:, model: commentable.to_gid } } }
    let(:user) { create(:user, :confirmed, organization:, extended_data:) }
    let(:commentable_path) { Decidim::ResourceLocatorPresenter.new(commentable).path }
    let(:authorizations) { %w(dummy_authorization_handler another_dummy_authorization_handler) }
    let!(:user_verification) { nil }

    before do
      sign_in
    end

    context "and there are no authorizations defined for the resource" do
      it "the user is redirected to the resource" do
        expect(page).to have_current_path commentable_path
        expect(page).to have_content "You have been successfully authorized"
      end
    end

    context "and there are authorizations defined for the resource" do
      let(:permissions) do
        {
          action => {
            authorization_handlers: {
              dummy_authorization_handler: {
                options: {
                  allowed_postal_codes: "1234, 4567"
                }
              }
            }
          }
        }
      end

      context "and the user is not verified with the authorization" do
        it "the user onboarding extended data is maintained" do
          expect(user.reload.extended_data["onboarding"]).to be_present
        end

        context "when there is only an authorization" do
          it "the user is redirected to a page with the authorizations required to perform the action" do
            expect(page).to have_current_path decidim_verifications.new_authorization_path(
              handler: "dummy_authorization_handler",
              postal_codes: "1234,4567",
              redirect_url: decidim_verifications.onboarding_pending_authorizations_path
            )
            expect(page).to have_content "We need to verify your identity"
            expect(page).to have_content "Verify with Example authorization"
          end
        end

        context "when there are more than one authorization" do
          let(:permissions) do
            {
              action => {
                authorization_handlers: {
                  dummy_authorization_handler: {
                    options: {
                      allowed_postal_codes: "1234, 4567"
                    }
                  },
                  another_dummy_authorization_handler: {
                    options: {}
                  }
                }
              }
            }
          end

          it "the user is redirected to a page with the authorizations required to perform the action" do
            expect(page).to have_current_path decidim_verifications.onboarding_pending_authorizations_path
            expect(page).to have_content "You are almost ready to comment on the #{translated_attribute(commentable.title)} dummy resource"
            expect(page).to have_css("a[data-verification]", text: "Example authorization")
            expect(page).to have_css("a[data-verification]", text: "Another example authorization")
          end
        end
      end

      context "and the user is verified with the authorization" do
        let(:document_number) { "123456789X" }
        let!(:user_verification) { create(:authorization, :granted, user:, name: "dummy_authorization_handler", metadata:) }

        context "and the authorization is granted with metadata which meets the conditions to allow the action" do
          let(:metadata) do
            {
              "postal_code" => "1234",
              "document_number" => document_number
            }
          end

          it "the user onboarding extended data is removed" do
            expect(user.reload.extended_data["onboarding"]).to be_blank
          end

          it "the user is redirected to the resource with a success message" do
            expect(page).to have_current_path commentable_path
            expect(page).to have_content "You have been successfully authorized"
          end
        end

        context "and the authorization is granted with metadata which does not meet the conditions to allow the action" do
          let(:metadata) do
            {
              "postal_code" => "1111",
              "document_number" => document_number
            }
          end

          it "the user onboarding extended data is removed" do
            expect(user.reload.extended_data["onboarding"]).to be_blank
          end

          it "the user is redirected to the resource with a failed authorization message" do
            expect(page).to have_current_path commentable_path
            expect(page).to have_content "You are not authorized to comment in this resource"
          end
        end
      end
    end
  end

  private

  def visit_authorizations
    within_user_menu do
      click_on "My account"
    end

    click_on "Authorizations"
  end

  def sign_in
    visit decidim.root_path
    within "#main-bar" do
      click_on("Log in")
    end

    within "form.new_user", match: :first do
      fill_in :session_user_email, with: user.email
      fill_in :session_user_password, with: "decidim123456789"
      find("*[type=submit]").click
    end
  end
end
