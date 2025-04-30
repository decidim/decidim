# frozen_string_literal: true

require "spec_helper"

shared_examples_for "manage questionnaire responses" do
  let(:first_type) { "short_response" }
  let!(:first) do
    create(:questionnaire_question, questionnaire:, position: 1, question_type: first_type)
  end
  let!(:second) do
    create(:questionnaire_question, questionnaire:, position: 2, question_type: "single_option")
  end
  let!(:third) do
    create(:questionnaire_question, questionnaire:, position: 3, question_type: "files")
  end
  let(:questions) do
    [first, second, third]
  end

  context "when there are responses" do
    let!(:response1) { create(:response, questionnaire:, question: first) }
    let!(:response2) { create(:response, body: "second response", questionnaire:, question: first) }
    let!(:response3) { create(:response, questionnaire:, question: second) }
    let!(:file_response) { create(:response, :with_attachments, questionnaire:, question: third, body: nil, user: response3.user, session_token: response3.session_token) }

    it "shows the response admin link" do
      click_on "Questions"
      expect(page).to have_content("Responses")
    end

    context "and managing responses page" do
      before do
        click_on "Questions"
        click_on "Responses"
      end

      it "shows the responses page" do
        expect(page).to have_content(response1.body)
        expect(page).to have_content(response1.question.body["en"])
        expect(page).to have_content(response2.body)
        expect(page).to have_content(response2.question.body["en"])
      end

      it "shows the percentage" do
        expect(page).to have_content("33%")
      end

      it "has a detail link" do
        expect(page).to have_link("Show responses")
      end

      it "has an export link" do
        expect(page).to have_link(response1.body)
        expect(page).to have_link(response2.body)
        expect(page).to have_link("Export")
      end

      context "when no short response exist" do
        let(:first_type) { "long_response" }

        it "shows session token" do
          expect(page).to have_no_content(response1.body)
          expect(page).to have_content(response1.session_token)
          expect(page).to have_content(response2.session_token)
          expect(page).to have_content(response3.session_token)
          expect(page).to have_content("User identifier")
        end
      end

      context "when multiple response choice" do
        let(:first_type) { "multiple_option" }
        let!(:response1) { create(:response, questionnaire:, question: first, body: nil) }
        let!(:response_option) { create(:response_option, question: first) }
        let!(:response_choice) { create(:response_choice, response: response1, response_option:, body: translated(response_option.body, locale: I18n.locale)) }

        it "shows the responses page with custom body" do
          new_window = window_opened_by { find_all("a.action-icon.action-icon--eye").first.click }

          page.within_window(new_window) do
            within "#responses" do
              expect(page).to have_css("dt", text: translated(first.body))
              expect(page).to have_css("li", text: translated(response_option.body))
            end
          end
        end
      end
    end

    context "and managing individual response page" do
      let!(:response11) { create(:response, questionnaire:, body: "", user: response1.user, question: second) }

      before do
        click_on "Questions"
        click_on "Responses"
      end

      it "shows all the questions and responses" do
        click_on response1.body, match: :first
        expect(page).to have_content(first.body["en"])
        expect(page).to have_content(second.body["en"])
        expect(page).to have_content(response1.body)
      end

      it "first response has a next link" do
        click_on response1.body, match: :first
        expect(page).to have_link("Next ›")
        expect(page).to have_no_link("‹ Prev")
      end

      it "second response has prev/next links" do
        click_on response2.body, match: :first
        expect(page).to have_link("Next ›")
        expect(page).to have_link("‹ Prev")
      end

      it "third response has prev link" do
        click_on response3.session_token, match: :first
        expect(page).to have_no_link("Next ›")
        expect(page).to have_link("‹ Prev")
      end

      it "third response has download link for the attachments" do
        click_on response3.session_token, match: :first
        expect(page).to have_content(translated(file_response.attachments.first.title))
        expect(page).to have_content(translated(file_response.attachments.second.title))
      end

      context "when the file response does not have a title for the attachment" do
        let!(:file_response) { create(:response, questionnaire:, question: third, body: nil, user: response3.user, session_token: response3.session_token) }

        before do
          create(:attachment, :with_image, attached_to: file_response, title: {}, description: {})
        end

        it "third response has download link for the attachments" do
          click_on response3.session_token, match: :first
          expect(page).to have_content("Download attachment")
        end
      end
    end
  end
end
