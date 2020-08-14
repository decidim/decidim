# frozen_string_literal: true

require "spec_helper"

describe "Meeting registrations", type: :system do
  include_context "with a component"
  let(:manifest_name) { "meetings" }

  let!(:questionnaire) { create(:questionnaire) }
  let!(:question) { create(:questionnaire_question, questionnaire: questionnaire, position: 0) }
  let!(:meeting) { create :meeting, component: component, questionnaire: questionnaire }
  let!(:user) { create :user, :confirmed, organization: organization }

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
      registrations_enabled: registrations_enabled,
      registration_form_enabled: registration_form_enabled,
      available_slots: available_slots,
      registration_terms: registration_terms
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
        create(:registration, meeting: meeting, user: user)
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
              page.find(".button.expanded").click
            end

            expect(page).to have_content("successfully")

            expect(page).to have_css(".button", text: "GOING")
            expect(page).to have_text("19 slots remaining")
            expect(page).to have_text("Stop following")
          end
        end

        context "and they ARE part of a verified user group" do
          let!(:user_group) { create :user_group, :verified, users: [user], organization: organization }

          it "they can join the meeting representing a group" do
            visit_meeting

            within ".card.extra" do
              click_button "Join meeting"
            end

            within "#meeting-registration-confirm-#{meeting.id}" do
              expect(page).to have_content "I represent a group"
              page.find("input#user_group").click
              select user_group.name, from: :join_meeting_user_group_id
              page.find(".button.expanded").click
            end

            expect(page).to have_content("successfully")

            expect(page).to have_css(".button", text: "GOING")
            expect(page).to have_text("19 slots remaining")

            expect(page).to have_text("ATTENDING ORGANIZATIONS")
            expect(page).to have_text(user_group.name)
          end
        end
      end
    end

    context "and has a registration form" do
      let(:registration_form_enabled) { true }

      it_behaves_like "has questionnaire"

      context "when the registration form has no questions" do
        before do
          questionnaire.questions.last.delete
          login_as user, scope: :user
        end

        it "shows the registration form without questions" do
          visit questionnaire_public_path

          expect(page).to have_i18n_content(questionnaire.title, upcase: true)
          expect(page).to have_i18n_content(questionnaire.description)

          expect(page).to have_no_i18n_content(question.body)

          expect(page).to have_button("Submit")
        end
      end
    end

    context "and the user is going to the meeting" do
      let!(:answer) { create(:answer, questionnaire: questionnaire, question: question, user: user) }
      let!(:registration) { create(:registration, meeting: meeting, user: user) }

      before do
        login_as user, scope: :user
      end

      it "shows the registration code" do
        visit_meeting

        expect(page).to have_css(".registration_code")
        expect(page).to have_content(registration.code)
      end

      context "when showing the registration code validation state" do
        it "shows validation pending if not validated" do
          visit_meeting

          expect(registration.validated_at).to be(nil)
          expect(page).to have_content("VALIDATION PENDING")
        end

        it "shows validated if validated" do
          registration.update validated_at: Time.current
          visit_meeting

          expect(registration.validated_at).not_to be(nil)
          expect(page).to have_content("VALIDATED")
        end
      end

      it "they can leave the meeting" do
        visit_meeting
        click_button "Going"

        expect(page).to have_content("successfully")
        expect(questionnaire.answers.where(user: user).empty?).to be(true)

        expect(page).to have_css(".button", text: "JOIN MEETING")
        expect(page).to have_text("20 slots remaining")
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
