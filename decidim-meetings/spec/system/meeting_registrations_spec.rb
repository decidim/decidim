# frozen_string_literal: true

require "spec_helper"

describe "Meeting registrations", type: :system do
  include_context "with a component"
  let(:manifest_name) { "meetings" }

  let!(:questionnaire) { create(:questionnaire) }
  let!(:question) { create(:questionnaire_question, questionnaire:, position: 0) }
  let!(:meeting) { create :meeting, :published, component:, questionnaire: }
  let!(:user) { create :user, :confirmed, organization: }

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
  end

  context "when meeting registrations are not enabled" do
    let(:registrations_enabled) { false }

    it "the registration button is not visible" do
      visit_meeting

      within ".card.extra" do
        expect(page).not_to have_button("JOIN MEETING")
        expect(page).not_to have_text("20 slots remaining")
      end
    end

    context "and registration form is also enabled" do
      let(:registration_form_enabled) { true }

      it "can't answer the registration form" do
        visit questionnaire_public_path

        expect(page).to have_i18n_content(questionnaire.title, upcase: true)
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

        within ".card.extra" do
          expect(page).to have_css("button[disabled]", text: "NO SLOTS AVAILABLE")
          expect(page).to have_text("0 slots remaining")
        end
      end

      context "and registration form is enabled" do
        let(:registration_form_enabled) { true }

        before do
          login_as user, scope: :user
        end

        it "can't answer the registration form" do
          visit questionnaire_public_path

          expect(page).to have_i18n_content(questionnaire.title, upcase: true)
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

          within ".card.extra" do
            click_button "Join meeting"
          end

          expect(page).to have_css("#loginModal", visible: :visible)
        end

        context "and caching is enabled", :caching do
          it "they have the option to sign in with different languages" do
            visit_meeting

            within ".card.extra" do
              click_button "Join meeting"
            end

            within "#loginModal" do
              expect(page).to have_content("Sign in with Facebook")
              find(".close-button").click
            end

            within_language_menu do
              click_link "Català"
            end

            within ".card.extra" do
              click_button "Unir-se a la trobada"
            end

            within "#loginModal" do
              expect(page).to have_content("Inicia sessió amb Facebook")
            end
          end
        end

        context "and registration form is enabled" do
          let(:registration_form_enabled) { true }

          it "they have the option to sign in" do
            visit questionnaire_public_path

            expect(page).to have_i18n_content(questionnaire.title, upcase: true)
            expect(page).to have_i18n_content(questionnaire.description)

            expect(page).not_to have_css(".form.answer-questionnaire")

            within ".questionnaire-question_readonly" do
              expect(page).to have_i18n_content(question.body)
            end

            expect(page).to have_content("Sign in with your account or sign up to answer the form")
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

            within ".card.extra" do
              click_button "Join meeting"
            end

            within "#meeting-registration-confirm-#{meeting.id}" do
              expect(page).to have_content "A legal text"
              expect(page).to have_content "Show my attendance publicly"
              expect(page).to have_field("public_participation", checked: false)
              page.find(".button.expanded").click
            end

            within_flash_messages do
              expect(page).to have_content("successfully")
            end

            expect(page).to have_text("You have signed up for this meeting")
            expect(page).to have_css(".button", text: "CANCEL YOUR REGISTRATION")
            expect(page).to have_text("19 slots remaining")
            expect(page).to have_text("Stop following")
            expect(page).to have_no_text("ATTENDING PARTICIPANTS")
            expect(page).to have_no_css("#list-of-public-participants")
          end

          it "they can join the meeting and configure their participation to be shown publicly" do
            visit_meeting

            within ".card.extra" do
              click_button "Join meeting"
            end

            within "#meeting-registration-confirm-#{meeting.id}" do
              expect(page).to have_content "Show my attendance publicly"
              expect(page).to have_field("public_participation", checked: false)
              page.find("input#public_participation").click
              page.find(".button.expanded").click
            end

            expect(page).to have_content("successfully")

            expect(page).to have_text("You have signed up for this meeting")
            expect(page).to have_text("19 slots remaining")
            expect(page).to have_text("Stop following")
            expect(page).to have_text("ATTENDING PARTICIPANTS")
            within "#list-of-public-participants" do
              expect(page).to have_text(user.name)
            end
          end

          it "they can join the meeting if they are already following it" do
            create(:follow, followable: meeting, user:)

            visit_meeting

            within ".card.extra" do
              click_button "Join meeting"
            end

            within "#meeting-registration-confirm-#{meeting.id}" do
              expect(page).to have_content "A legal text"
              expect(page).to have_content "Show my attendance publicly"
              expect(page).to have_field("public_participation", checked: false)
              page.find(".button.expanded").click
            end

            within_flash_messages do
              expect(page).to have_content("successfully")
            end

            expect(page).to have_text("You have signed up for this meeting")
            expect(page).to have_css(".button", text: "CANCEL YOUR REGISTRATION")
            expect(page).to have_text("19 slots remaining")
            expect(page).to have_text("Stop following")
          end
        end

        context "and they ARE part of a verified user group" do
          let!(:user_group) { create :user_group, :verified, users: [user], organization: }

          it "they can join the meeting representing a group and appear in the attending organizations list" do
            visit_meeting

            within ".card.extra" do
              click_button "Join meeting"
            end

            within "#meeting-registration-confirm-#{meeting.id}" do
              expect(page).to have_content "I represent a group"
              expect(page).to have_content "Show my attendance publicly"
              expect(page).to have_field("public_participation", checked: false)
              page.find("input#public_participation").click
              page.find("input#user_group").click
              select user_group.name, from: :join_meeting_user_group_id
              page.find("input#public_participation").click
              page.find(".button.expanded").click
            end

            within_flash_messages do
              expect(page).to have_content("successfully")
            end

            expect(page).to have_text("You have signed up for this meeting")
            expect(page).to have_css(".button", text: "CANCEL YOUR REGISTRATION")
            expect(page).to have_text("19 slots remaining")

            expect(page).to have_text("ATTENDING ORGANIZATIONS")
            expect(page).to have_text(user_group.name)
            expect(page).to have_no_text("ATTENDING PARTICIPANTS")
            expect(page).to have_no_css("#list-of-public-participants")
          end
        end
      end
    end

    context "and has a registration form" do
      let(:registration_form_enabled) { true }

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

          expect(page).to have_i18n_content(questionnaire.title, upcase: true)
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

          input_element = find("input[type='file']", visible: :all)
          input_element.attach_file(Decidim::Dev.asset("verify_user_groups.csv"))

          expect(page).to have_field("public_participation", checked: false)
          find(".tos-agreement").set(true)
          click_button "Submit"

          within ".confirm-modal-footer" do
            find("a.button[data-confirm-ok]").click
          end

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

        within ".confirm-modal-content" do
          expect(page).to have_content("Are you sure you want to cancel your registration for this meeting?")
        end
      end

      it "they can leave the meeting" do
        visit_meeting

        accept_confirm { click_button "Cancel your registration" }

        within_flash_messages do
          expect(page).to have_content("successfully")
        end

        expect(page).to have_css(".button", text: "JOIN MEETING")
        expect(page).to have_text("20 slots remaining")
      end

      context "when registration code is enabled" do
        before do
          component.update!(settings: { registration_code_enabled: true })
        end

        it "shows the registration code" do
          visit_meeting

          expect(page).to have_css(".registration_code")
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
          expect(page).to have_no_content("VALIDATION PENDING")
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
          expect(page).to have_no_content("VALIDATED")
        end
      end

      context "and registration form is enabled" do
        let(:registration_form_enabled) { true }

        it "can't answer the registration again" do
          visit questionnaire_public_path

          expect(page).to have_i18n_content(questionnaire.title, upcase: true)
          expect(page).to have_i18n_content(questionnaire.description)

          expect(page).to have_no_i18n_content(question.body)

          expect(page).to have_content("You have already answered this form.")
        end
      end
    end
  end
end
