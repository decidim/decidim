# frozen_string_literal: true

require "spec_helper"

shared_examples_for "manage questionnaire answers" do
  let(:first_type) { "short_answer" }
  let!(:first) do
    create :questionnaire_question, questionnaire: questionnaire, position: 1, question_type: first_type
  end
  let!(:second) do
    create :questionnaire_question, questionnaire: questionnaire, position: 2, question_type: "single_option"
  end
  let(:questions) do
    [first, second]
  end

  context "when there are no answers" do
    it "do not answer admin link" do
      visit questionnaire_edit_path
      expect(page).to have_content("No answers yet")
    end
  end

  context "when there are answers" do
    let!(:answer1) { create :answer, questionnaire: questionnaire, question: first }
    let!(:answer2) { create :answer, body: "second answer", questionnaire: questionnaire, question: first }
    let!(:answer3) { create :answer, questionnaire: questionnaire, question: second }

    it "shows the answer admin link" do
      visit questionnaire_edit_path
      expect(page).to have_content("Show responses")
    end

    context "and managing answers page" do
      before do
        visit questionnaire_edit_path
        click_link "Show responses"
      end

      it "shows the anwers page" do
        expect(page).to have_content(answer1.body)
        expect(page).to have_content(answer1.question.body["en"])
        expect(page).to have_content(answer2.body)
        expect(page).to have_content(answer2.question.body["en"])
      end

      it "shows the percentage" do
        expect(page).to have_content("50%")
      end

      it "has a detail link" do
        expect(page).to have_link("Show answers")
      end

      it "has an export link" do
        expect(page).to have_link(answer1.body)
        expect(page).to have_link(answer2.body)
        expect(page).to have_link("Export")
      end

      context "when no short answer exist" do
        let(:first_type) { "long_answer" }

        it "shows session token" do
          expect(page).not_to have_content(answer1.body)
          expect(page).to have_content(answer1.session_token)
          expect(page).to have_content(answer2.session_token)
          expect(page).to have_content(answer3.session_token)
          expect(page).to have_content("User identifier")
        end
      end
    end

    context "and managing individual answer page" do
      let!(:answer11) { create :answer, questionnaire: questionnaire, body: "", user: answer1.user, question: second }

      before do
        visit questionnaire_edit_path
        click_link "Show responses"
      end

      it "shows all the questions and responses" do
        click_link answer1.body, match: :first
        expect(page).to have_content(first.body["en"])
        expect(page).to have_content(second.body["en"])
        expect(page).to have_content(answer1.body)
      end

      it "first answer has a next link" do
        click_link answer1.body, match: :first
        expect(page).to have_link("Next ›")
        expect(page).not_to have_link("‹ Prev")
      end

      it "second answer has prev/next links" do
        click_link answer2.body, match: :first
        expect(page).to have_link("Next ›")
        expect(page).to have_link("‹ Prev")
      end

      it "third answer has prev link" do
        click_link answer3.session_token, match: :first
        expect(page).not_to have_link("Next ›")
        expect(page).to have_link("‹ Prev")
      end
    end
  end
end
