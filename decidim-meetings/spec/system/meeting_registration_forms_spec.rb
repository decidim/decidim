# frozen_string_literal: true

require "spec_helper"

describe "Meeting registration forms", type: :system do
  include_context "with a component"
  let(:manifest_name) { "meetings" }

  let(:meetings_count) { 2 }
  let!(:meetings) do
    create_list(:meeting, meetings_count, component: component)
  end
  let(:meeting) { meetings.first }
  let!(:user) { create :user, :confirmed, organization: organization }

  let(:registrations_enabled) { true }
  let(:available_slots) { 20 }

  let!(:questionnaire) { create(:questionnaire, meeting: meeting, questionnaire_type: "registration") }
  let!(:questionnaire_question) { create(:questionnaire_question, questionnaire: questionnaire, position: 0) }

  def visit_registration_form
    visit Decidim::EngineRouter.main_proxy(meeting.component).join_meeting_registration_path(meeting)
  end

  before do
    meeting.update!(
      registrations_enabled: registrations_enabled,
      available_slots: available_slots
    )
  end

  context "when meeting registrations are not enabled" do
    let(:registrations_enabled) { false }

    it "they are redirect to the meeting page" do
      visit_registration_form

      expect(page).to have_current_path(resource_locator(meeting).path)
      expect(page).to have_content("not authorized")
    end
  end

  context "when meeting registrations are enabled" do
    context "and the meeting has not a slot available" do
      let(:available_slots) { 1 }

      before do
        create(:registration, meeting: meeting, user: user)
      end

      context "and the user is not logged in" do
        it "they are redirect to the meeting page" do
          visit_registration_form

          expect(page).to have_current_path(resource_locator(meeting).path)
          expect(page).to have_content("not authorized")
        end
      end

      context "and the user is logged in" do
        before do
          login_as user, scope: :user
        end

        it "the registration form is closed" do
          visit_registration_form

          expect(page).to have_i18n_content(questionnaire.title, upcase: true)
          expect(page).to have_i18n_content(questionnaire.description)

          expect(page).to have_no_i18n_content(questionnaire_question.body)

          expect(page).to have_content("The questionnaire is closed and cannot be answered.")
        end
      end
    end

    context "and the meeting has a slot available" do
      context "and the user is not logged in" do
        it "they are redirect to the meeting page" do
          visit_registration_form

          expect(page).to have_current_path(resource_locator(meeting).path)
          expect(page).to have_content("not authorized")
        end
      end

      context "and the user is logged in" do
        before do
          login_as user, scope: :user
        end

        it "they can join the meeting" do
          visit_registration_form

          expect(page).to have_i18n_content(questionnaire.title, upcase: true)

          fill_in questionnaire_question.body["en"], with: "My first answer"

          check "questionnaire_tos_agreement"

          accept_confirm { click_button "Submit" }

          expect(page).to have_content("successfully")

          within ".card.extra" do
            expect(page).to have_css(".button", text: "GOING")
            expect(page).to have_text("19 slots remaining")
          end
        end

        context "and the meeting does not have a registration form" do
          before do
            questionnaire.destroy
          end

          it "they are redirect to the meeting page" do
            visit_registration_form

            expect(page).to have_current_path(resource_locator(meeting).path)
          end
        end
      end
    end

    context "and the user is going to the meeting" do
      before do
        create(:registration, meeting: meeting, user: user)
        create(:questionnaire_answer, questionnaire: questionnaire, question: questionnaire_question, user: user)
        login_as user, scope: :user
      end

      it "the registration form is already answered" do
        visit_registration_form

        expect(page).to have_i18n_content(questionnaire.title, upcase: true)
        expect(page).to have_i18n_content(questionnaire.description)

        expect(page).to have_no_i18n_content(questionnaire_question.body)

        expect(page).to have_content("You have already answered this questionnaire.")
      end
    end
  end
end
