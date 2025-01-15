# frozen_string_literal: true

require "spec_helper"

describe "ephemeral action authorization" do
  include_context "with a component"

  let(:manifest_name) { "proposals" }
  let(:available_authorizations) { %w(ephemeral_dummy_authorization_handler dummy_authorization_handler) }
  let!(:organization) do
    create(:organization, available_authorizations:)
  end

  let!(:proposal) { create(:proposal, component:) }

  let!(:component) do
    create(
      :proposal_component,
      :with_creation_enabled,
      manifest:,
      participatory_space:,
      permissions:
    )
  end

  before do
    switch_to_host(organization.host)
  end

  context "with not user signed in" do
    context "and action authorized with ephemeral authorization" do
      let(:scope) { create(:scope, organization:, name: { en: "Scope" }) }
      let(:permissions) do
        {
          create: {
            authorization_handlers: {
              ephemeral_dummy_authorization_handler: {
                options: {
                  allowed_postal_codes: "1234, 4567",
                  allowed_scope_id: scope.id
                }
              }
            }
          }
        }
      end

      before do
        visit main_component_path(component)
      end

      it "creates an ephemeral user session" do
        expect { click_on "New proposal" }.to change { Decidim::User.ephemeral.count }.by(1)

        expect(page).to have_link("Close", href: "/users/sign_out")
      end

      context "when ephemeral session is initiated" do
        before do
          click_on "New proposal"
        end

        it "redirects to ephemeral verification form" do
          expect(page).to have_content("Please verify your identity to proceed")
          expect(page).to have_css("h1", text: "Verify with Ephemeral example authorization")
        end

        it "displays a tos acceptance item" do
          expect(page).to have_content("By verifying your identity you accept the terms of service.")
        end
      end

      context "when the user fills the ephemeral verification form" do
        let(:document_number) { "0123456789X" }
        let(:postal_code) { "1234" }
        let(:birthdate) { 33.years.ago.strftime("%d/%m/%Y") }

        before do
          click_on "New proposal"

          fill_in :authorization_handler_document_number, with: document_number
          fill_in :authorization_handler_postal_code, with: postal_code
          fill_in_datepicker :authorization_handler_birthday_date, with: birthdate
          select "Scope", from: :authorization_handler_scope_id
        end

        context "and does not check tos agreement" do
          it "prevents submission of form" do
            click_on "Send"

            expect(page).to have_content("There was a problem creating the authorization.")

            within "#card__tos" do
              expect(page).to have_content("must be accepted")
            end
          end
        end

        context "and checks tos agreement and submits the form" do
          before do
            check :authorization_handler_tos_agreement
            click_on "Send"
          end

          context "when data matches the authorization criteria" do
            it "the user is authorized and redirected to the action" do
              expect(page).to have_content "You have been successfully authorized"
              expect(page).to have_content "You have started a guest session, you can now participate"

              expect(page).to have_css "h1", text: "Create your proposal"
            end

            it "the user is able to recover its session verifying with the same data" do
              fill_in :proposal_title, with: "This is a new proposal"
              fill_in :proposal_body, with: "The proposal includes a lot of ideas"
              click_on "Continue"

              expect(page).to have_content "Proposal successfully created. Saved as a Draft."

              accept_confirm do
                find("#main-bar [data-close]").click
              end

              visit main_component_path(component)

              click_on "New proposal"

              fill_in :authorization_handler_document_number, with: document_number
              fill_in :authorization_handler_postal_code, with: postal_code
              fill_in_datepicker :authorization_handler_birthday_date, with: birthdate
              select "Scope", from: :authorization_handler_scope_id
              check :authorization_handler_tos_agreement
              click_on "Send"

              expect(page).to have_content "Edit proposal draft"

              expect(page).to have_field :proposal_title, with: "This is a new proposal"
              expect(page).to have_field :proposal_body, with: "The proposal includes a lot of ideas"
            end
          end

          context "when data does not match the authorization criteria" do
            let(:postal_code) { "0000" }
            let(:valid_postal_code) { "1234" }

            it "the user is not allowed to perform the action and signed out" do
              expect(page).to have_no_content "You have been successfully authorized, now you can create a proposal in the component"
              expect(page).to have_content "You are not authorized to perform this action."
              expect(page).to have_content "Your guest session has finished"
              expect(page).to have_link "Log in"
            end

            it "the action is forbidden and the ephemeral session closed verifying with the same verification unique id and the same invalid metadata" do
              visit main_component_path(component)

              click_on "New proposal"

              fill_in :authorization_handler_document_number, with: document_number
              fill_in :authorization_handler_postal_code, with: postal_code
              fill_in_datepicker :authorization_handler_birthday_date, with: birthdate
              select "Scope", from: :authorization_handler_scope_id
              check :authorization_handler_tos_agreement
              click_on "Send"

              expect(page).to have_content "You are not authorized to perform this action."
              expect(page).to have_content "Your guest session has finished"
              expect(page).to have_link "Log in"
            end

            it "the action is allowed and the ephemeral session recovered verifying with the same verification unique id and metadata matching the authorization criteria" do
              visit main_component_path(component)

              click_on "New proposal"

              fill_in :authorization_handler_document_number, with: document_number
              fill_in :authorization_handler_postal_code, with: valid_postal_code
              fill_in_datepicker :authorization_handler_birthday_date, with: birthdate
              select "Scope", from: :authorization_handler_scope_id
              check :authorization_handler_tos_agreement
              click_on "Send"
              expect(page).to have_content "You have been successfully authorized"
              expect(page).to have_content "You have started a guest session, you can now participate"

              expect(page).to have_css "h1", text: "Create your proposal"
            end
          end
        end
      end
    end

    context "and action authorized with regular authorization" do
      let(:scope) { create(:scope, organization:) }
      let(:permissions) do
        {
          create: {
            authorization_handlers: {
              dummy_authorization_handler: {
                options: {
                  allowed_postal_codes: "1234, 4567",
                  allowed_scope_id: scope.id
                }
              }
            }
          }
        }
      end

      it "redirects to authorization" do
        visit main_component_path(component)
        expect { click_on "New proposal" }.not_to change(Decidim::User, :count)

        expect(page).to have_no_content("Verify with Example authorization")
        expect(page).to have_css("#loginModal", visible: :visible)
        expect(page).to have_content("Please log in")
      end
    end
  end
end
