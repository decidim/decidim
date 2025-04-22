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

  def see_questionnaire_questions; end

  before do
    stub_geocoding_coordinates([meeting.latitude, meeting.longitude])
    meeting.update!(
      registrations_enabled:,
      registration_form_enabled:,
      available_slots:,
      registration_terms:
    )
  end

  context "when meeting registrations are not enabled" do
    let(:registrations_enabled) { false }

    it "the registration button is not visible" do
      visit_meeting

      expect(page).to have_no_button("Register")
      expect(page).to have_no_text("20 slots remaining")
    end

    context "and registration form is also enabled" do
      let(:registration_form_enabled) { true }

      it "cannot response the registration form" do
        visit questionnaire_public_path

        expect(page).to have_i18n_content(questionnaire.title)
        expect(page).to have_i18n_content(questionnaire.description, strip_tags: true)

        expect(page).to have_no_i18n_content(question.body)

        expect(page).to have_content("The form is closed and cannot be responded")
      end
    end
  end

  context "when meeting registrations are enabled" do
    context "and the meeting has not a slot available" do
      let(:available_slots) { 1 }

      before do
        create(:registration, meeting:, user:)
      end

      it "shows the waitlist button" do
        visit_meeting

        expect(page).to have_text("Join waitlist")
        expect(page).to have_text("0 slots remaining")
      end

      context "and registration form is enabled" do
        let(:registration_form_enabled) { true }

        before do
          login_as user, scope: :user
        end

        it "cannot response the registration form" do
          visit questionnaire_public_path

          expect(page).to have_i18n_content(questionnaire.title)
          expect(page).to have_i18n_content(questionnaire.description, strip_tags: true)

          expect(page).to have_no_i18n_content(question.body)

          expect(page).to have_content("The form is closed and cannot be responded")
        end
      end
    end

    context "and the meeting has a slot available" do
      context "and the user is not logged in" do
        it "they have the option to sign in" do
          visit_meeting

          click_on "Register"

          expect(page).to have_css("#loginModal", visible: :visible)
        end

        context "and caching is enabled", :caching do
          it "they have the option to sign in with different languages" do
            visit_meeting

            click_on "Register"

            within "#loginModal" do
              expect(page).to have_content("Forgot your password?")
              find("[data-dialog-close='loginModal']", match: :first).click
            end

            within_language_menu do
              click_on "Català"
            end

            click_on "Inscriu-te"

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
            expect(page).to have_i18n_content(questionnaire.description, strip_tags: true)

            expect(page).to have_no_css(".form.response-questionnaire")

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

        context "and the meeting is happening now" do
          before do
            meeting.update!(start_time: 1.hour.ago, end_time: 1.hour.from_now)
          end

          it "does not show the registration button" do
            visit_meeting

            expect(page).to have_no_css(".button", text: "Register")
          end
        end

        it "they can join the meeting and automatically follow it" do
          visit_meeting

          click_on "Register"

          within "#meeting-registration-confirm-#{meeting.id}" do
            expect(page).to have_content "A legal text"
            expect(page).to have_content "Show my attendance publicly"
            expect(page).to have_field("public_participation", checked: false)
            click_on "Confirm"
          end

          within_flash_messages do
            expect(page).to have_content("successfully")
          end

          expect(page).to have_css(".button", text: "Cancel your registration")
          expect(page).to have_text("19 slots remaining")
          find("#dropdown-trigger-resource-#{meeting.id}").click

          expect(page).to have_text("Stop following")
          expect(page).to have_no_text("Participants")
          expect(page).to have_no_css("#panel-participants")
        end

        it "they can join the meeting and configure their participation to be shown publicly" do
          visit_meeting

          click_on "Register"

          within "#meeting-registration-confirm-#{meeting.id}" do
            expect(page).to have_content "Show my attendance publicly"
            expect(page).to have_field("public_participation", checked: false)
            page.find("input#public_participation").click
            click_on "Confirm"
          end

          expect(page).to have_content("successfully")

          expect(page).to have_text("19 slots remaining")
          find("#dropdown-trigger-resource-#{meeting.id}").click
          expect(page).to have_text("Stop following")
          expect(page).to have_text("Participants")
          within "#panel-participants" do
            expect(page).to have_text(user.name)
          end
        end

        it "they can join the meeting if they are already following it" do
          create(:follow, followable: meeting, user:)

          visit_meeting

          click_on "Register"

          within "#meeting-registration-confirm-#{meeting.id}" do
            expect(page).to have_content "A legal text"
            expect(page).to have_content "Show my attendance publicly"
            expect(page).to have_field("public_participation", checked: false)
            click_on "Confirm"
          end

          within_flash_messages do
            expect(page).to have_content("successfully")
          end

          expect(page).to have_css(".button", text: "Cancel your registration")
          expect(page).to have_text("19 slots remaining")
          find("#dropdown-trigger-resource-#{meeting.id}").click
          expect(page).to have_text("Stop following")
        end
      end
    end

    context "and has a registration form" do
      let(:registration_form_enabled) { true }
      let(:callout_failure) { "There was a problem responding the form" }
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

        it "shows an empty page with a message" do
          visit questionnaire_public_path

          expect(page).to have_content("No questions configured for this form yet.")
        end
      end

      context "when the registration form has file question and file is invalid" do
        let!(:question) { create(:questionnaire_question, questionnaire:, position: 0, question_type: :files) }

        before do
          login_as user, scope: :user
        end

        it "shows errors for invalid file" do
          visit questionnaire_public_path

          dynamically_attach_file("questionnaire_responses_0_add_documents", Decidim::Dev.asset("verify_user_groups.csv"), keep_modal_open: true)

          expect(page).to have_content("Validation error!")
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

            expect(page).to have_no_content("An important announcement")
          end
        end
      end
    end

    context "and the user is going to the meeting" do
      let!(:response) { create(:response, questionnaire:, question:, user:) }
      let!(:registration) { create(:registration, meeting:, user:) }

      before do
        login_as user, scope: :user
      end

      it "shows the confirmation modal when leaving the meeting" do
        visit_meeting

        click_on "Cancel your registration"

        within ".meeting__cancelation-modal" do
          expect(page).to have_content("Are you sure you want to cancel your registration for this meeting?")
        end
      end

      it "they can leave the meeting" do
        visit_meeting

        click_on "Cancel your registration"

        within ".meeting__cancelation-modal" do
          click_on "Cancel your registration"
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

        it "allows user to see the registration code" do
          visit_meeting

          click_on("Your registration and QR code")
          expect(page).to have_content(registration.code)
        end
      end

      context "when registration code is disabled" do
        before do
          component.update!(settings: { registration_code_enabled: false })
        end

        it "does not show the registration code" do
          visit_meeting

          expect(page).to have_no_css(".registration_code")
          expect(page).to have_no_content(registration.code)
          expect(page).to have_no_content("Your registration and QR code")
        end
      end

      context "and registration form is enabled" do
        let(:registration_form_enabled) { true }

        it "cannot response the registration again" do
          visit questionnaire_public_path

          expect(page).to have_i18n_content(questionnaire.title)
          expect(page).to have_i18n_content(questionnaire.description, strip_tags: true)

          expect(page).to have_no_i18n_content(question.body)

          expect(page).to have_content("You have already responded this form.")
        end
      end
    end
  end

  def see_questionnaire_questions; end
end
