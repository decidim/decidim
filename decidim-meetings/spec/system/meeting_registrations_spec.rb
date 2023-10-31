# frozen_string_literal: true

require "spec_helper"

describe "Meeting registrations" do
  include_context "with a component"
  let(:manifest_name) { "meetings" }

  let!(:questionnaire) { create(:questionnaire) }
  let!(:question) { create(:questionnaire_question, questionnaire:, position: 0) }
  let!(:meeting) { create(:meeting, :published, component:, questionnaire:) }
  let!(:user) { create(:user, :confirmed, organization:) }

  let(:registrations_enabled) { true }
  let(:registration_form_enabled) { false }
  let(:available_slots) { 20 }
  let(:registration_terms) do
    {
      en: "A legal text",
      es: "Un texto legal",
      ca: "Un text legal"
    }
  end

  def visit_meeting
    visit resource_locator(meeting).path
  end

  def questionnaire_public_path
    Decidim::EngineRouter.main_proxy(component).join_meeting_registration_path(meeting_id: meeting.id)
  end

  before do
    meeting.update!(
      registrations_enabled:,
      registration_form_enabled:,
      available_slots:,
      registration_terms:
    )

    # Make static map requests not to fail with HTTP 500 (causes JS error)
    stub_request(:get, Regexp.new(Decidim.maps.fetch(:static).fetch(:url))).to_return(body: "")
  end

  context "when meeting registrations are not enabled" do
    let(:registrations_enabled) { false }

    it "the registration button is not visible" do
      visit_meeting

      expect(page).not_to have_button("Register")
      expect(page).not_to have_text("20 slots remaining")
    end

    context "and registration form is also enabled" do
      let(:registration_form_enabled) { true }

      it "cannot answer the registration form" do
        visit questionnaire_public_path

        expect(page).to have_i18n_content(questionnaire.title)
        expect(page).to have_i18n_content(questionnaire.description)

        expect(page).to have_no_i18n_content(question.body)

        expect(page).to have_content("The form is closed and cannot be answered")
      end
    end
  end

  context "when meeting registrations are enabled" do
    context "and the meeting has not a slot available" do
      let(:available_slots) { 1 }

      before do
        create(:registration, meeting:, user:)
      end

      it "the registration button is disabled" do
        visit_meeting

        expect(page).to have_css("button[disabled]", text: "No slots available")
        expect(page).to have_text("0 slots remaining")
      end

      context "and registration form is enabled" do
        let(:registration_form_enabled) { true }

        before do
          login_as user, scope: :user
        end

        it "cannot answer the registration form" do
          visit questionnaire_public_path

          expect(page).to have_i18n_content(questionnaire.title)
          expect(page).to have_i18n_content(questionnaire.description)

          expect(page).to have_no_i18n_content(question.body)

          expect(page).to have_content("The form is closed and cannot be answered")
        end
      end
    end

    context "and the meeting has a slot available" do
      context "and the user is not logged in" do
        it "they have the option to sign in" do
          visit_meeting

          click_button "Register"

          expect(page).to have_css("#loginModal", visible: :visible)
        end

        context "and caching is enabled", :caching do
          it "they have the option to sign in with different languages" do
            visit_meeting

            click_button "Register"

            within "#loginModal" do
              expect(page).to have_content("Forgot your password?")
              find("[data-dialog-close='loginModal']", match: :first).click
            end

            within_language_menu do
              click_link "Català"
            end

            click_button "Unir-se a la trobada"

            within "#loginModal" do
              expect(page).to have_content("Has oblidat la teva contrasenya?")
            end
          end
        end

        context "and registration form is enabled" do
          let(:registration_form_enabled) { true }

          it "they have the option to sign in" do
            visit questionnaire_public_path

            expect(page).to have_i18n_content(questionnaire.title)
            expect(page).to have_i18n_content(questionnaire.description)

            expect(page).not_to have_css(".form.answer-questionnaire")

            within "[data-question-readonly]" do
              expect(page).to have_i18n_content(question.body)
            end
          end
        end
      end

      context "and the user is logged in" do
        before do
          login_as user, scope: :user
        end

        context "and they ARE NOT part of a verified user group" do
          it "they can join the meeting and automatically follow it" do
            visit_meeting

            click_button "Register"

            within "#meeting-registration-confirm-#{meeting.id}" do
              expect(page).to have_content "A legal text"
              expect(page).to have_content "Show my attendance publicly"
              expect(page).to have_field("public_participation", checked: false)
              click_button "Confirm"
            end

            within_flash_messages do
              expect(page).to have_content("successfully")
            end

            expect(page).to have_css(".button", text: "Cancel your registration")
            expect(page).to have_text("19 slots remaining")
            expect(page).to have_text("Stop following")
            expect(page).not_to have_text("Participants")
            expect(page).not_to have_css("#panel-participants")
          end

          it "they can join the meeting and configure their participation to be shown publicly" do
            visit_meeting

            click_button "Register"

            within "#meeting-registration-confirm-#{meeting.id}" do
              expect(page).to have_content "Show my attendance publicly"
              expect(page).to have_field("public_participation", checked: false)
              page.find("input#public_participation").click
              click_button "Confirm"
            end

            expect(page).to have_content("successfully")

            expect(page).to have_text("19 slots remaining")
            expect(page).to have_text("Stop following")
            expect(page).to have_text("Participants")
            within "#panel-participants" do
              expect(page).to have_text(user.name)
            end
          end

          it "they can join the meeting if they are already following it" do
            create(:follow, followable: meeting, user:)

            visit_meeting

            click_button "Register"

            within "#meeting-registration-confirm-#{meeting.id}" do
              expect(page).to have_content "A legal text"
              expect(page).to have_content "Show my attendance publicly"
              expect(page).to have_field("public_participation", checked: false)
              click_button "Confirm"
            end

            within_flash_messages do
              expect(page).to have_content("successfully")
            end

            expect(page).to have_css(".button", text: "Cancel your registration")
            expect(page).to have_text("19 slots remaining")
            expect(page).to have_text("Stop following")
          end
        end

        context "and they ARE part of a verified user group" do
          let!(:user_group) { create(:user_group, :verified, users: [user], organization:) }

          it "they can join the meeting representing a group and appear in the attending organizations list" do
            visit_meeting

            click_button "Register"

            within "#meeting-registration-confirm-#{meeting.id}" do
              expect(page).to have_content "I represent a group"
              expect(page).to have_content "Show my attendance publicly"
              expect(page).to have_field("public_participation", checked: false)
              page.find("input#public_participation").click
              page.find("input#user_group").click
              select user_group.name, from: :join_meeting_user_group_id
              page.find("input#public_participation").click
              click_button "Confirm"
            end

            within_flash_messages do
              expect(page).to have_content("successfully")
            end

            expect(page).to have_css(".button", text: "Cancel your registration")
            expect(page).to have_text("19 slots remaining")

            expect(page).to have_text("Organization")
            expect(page).to have_text(user_group.name)
            expect(page).not_to have_text("Participants")
            expect(page).to have_css("#panel-organizations")
            expect(page).not_to have_css("#panel-participants")
          end
        end
      end
    end

    context "and has a registration form" do
      let(:registration_form_enabled) { true }
      let(:callout_failure) { "There was a problem answering the form" }
      let(:callout_success) { <<~EOCONTENT.strip.gsub("\n", " ") }
        You have joined the meeting successfully.
        Because you have registered for this meeting, you will be notified if there are updates on it.
      EOCONTENT

      it_behaves_like "has questionnaire"

      context "when the user is following the meeting" do
        let!(:follow) { create(:follow, followable: meeting, user:) }

        it_behaves_like "has questionnaire"
      end

      context "when the registration form has no questions" do
        before do
          questionnaire.questions.last.delete
          login_as user, scope: :user
        end

        it "shows the registration form without questions" do
          visit questionnaire_public_path

          expect(page).to have_i18n_content(questionnaire.title)
          expect(page).to have_i18n_content(questionnaire.description)
          expect(page).to have_content "Show my attendance publicly"
          expect(page).to have_field("public_participation", checked: false)

          expect(page).to have_no_i18n_content(question.body)

          expect(page).to have_button("Submit")
        end
      end

      context "when the registration form has file question and file is invalid" do
        let!(:question) { create(:questionnaire_question, questionnaire:, position: 0, question_type: :files) }

        before do
          login_as user, scope: :user
        end

        it "shows errors for invalid file" do
          visit questionnaire_public_path

          dynamically_attach_file("questionnaire_responses_0_add_documents", Decidim::Dev.asset("verify_user_groups.csv"))

          expect(page).to have_field("public_participation", checked: false)
          find("#questionnaire_tos_agreement").set(true)
          accept_confirm { click_button "Submit" }

          expect(page).to have_content("Needs to be reattached")
        end

        context "and the announcement for the meeting is configured" do
          before do
            component.update!(
              settings: {
                announcement: {
                  en: "An important announcement",
                  es: "Un aviso muy importante",
                  ca: "Un avís molt important"
                }
              }
            )
          end

          it "the user should not see it" do
            visit questionnaire_public_path

            expect(page).not_to have_content("An important announcement")
          end
        end
      end
    end

    context "and the user is going to the meeting" do
      let!(:answer) { create(:answer, questionnaire:, question:, user:) }
      let!(:registration) { create(:registration, meeting:, user:) }

      before do
        login_as user, scope: :user
      end

      it "shows the confirmation modal when leaving the meeting" do
        visit_meeting

        click_button "Cancel your registration"

        within ".meeting__cancelation-modal" do
          expect(page).to have_content("Are you sure you want to cancel your registration for this meeting?")
        end
      end

      it "they can leave the meeting" do
        visit_meeting

        click_button "Cancel your registration"
        within ".meeting__cancelation-modal" do
          click_button "Cancel your registration"
        end

        within_flash_messages do
          expect(page).to have_content("successfully")
        end

        expect(page).to have_css(".button", text: "Register")
        expect(page).to have_text("20 slots remaining")
      end

      context "when registration code is enabled" do
        before do
          component.update!(settings: { registration_code_enabled: true })
        end

        it "shows the registration code" do
          visit_meeting

          expect(page).to have_content("Your registration code")
          expect(page).to have_content(registration.code)
        end
      end

      context "when registration code is disabled" do
        before do
          component.update!(settings: { registration_code_enabled: false })
        end

        it "does not show the registration code" do
          visit_meeting

          expect(page).not_to have_css(".registration_code")
          expect(page).not_to have_content(registration.code)
        end
      end

      context "when showing the registration code validation state with registration code enabled" do
        before do
          component.update!(settings: { registration_code_enabled: true })
        end

        it "shows validation pending if not validated" do
          visit_meeting

          expect(registration.validated_at).to be_nil
          expect(page).to have_content("VALIDATION PENDING")
        end
      end

      context "when not showing the registration code validation state with registration code disabled" do
        before do
          component.update!(settings: { registration_code_enabled: false })
        end

        it "shows validation pending if not validated" do
          visit_meeting

          expect(registration.validated_at).to be_nil
          expect(page).not_to have_content("VALIDATION PENDING")
        end
      end

      context "when showing the registration code validated for registration code enabled" do
        before do
          component.update!(settings: { registration_code_enabled: true })
        end

        it "shows validated if validated" do
          registration.update validated_at: Time.current
          visit_meeting

          expect(registration.validated_at).not_to be_nil
          expect(page).to have_content("VALIDATED")
        end
      end

      context "when not showing the registration code validated for registration code disabled" do
        before do
          component.update!(settings: { registration_code_enabled: false })
        end

        it "shows validated if validated" do
          registration.update validated_at: Time.current
          visit_meeting

          expect(registration.validated_at).not_to be_nil
          expect(page).not_to have_content("VALIDATED")
        end
      end

      context "and registration form is enabled" do
        let(:registration_form_enabled) { true }

        it "cannot answer the registration again" do
          visit questionnaire_public_path

          expect(page).to have_i18n_content(questionnaire.title)
          expect(page).to have_i18n_content(questionnaire.description)

          expect(page).to have_no_i18n_content(question.body)

          expect(page).to have_content("You have already answered this form.")
        end
      end
    end
  end
end
