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
      expect(page).to have_content("NO ANSWERS YET")
    end
  end

  context "when there are answers" do
    let!(:answer) { create :answer, questionnaire: questionnaire, question: first }

    it "shows the answer admin link" do
      visit questionnaire_edit_path
      expect(page).to have_content("SHOW RESPONSES")
    end

    context "and managing answers page" do
      before do
        visit questionnaire_edit_path
        click_link "Show responses"
      end

      it "shows the anwers page" do
        expect(page).to have_content(answer.body)
        expect(page).to have_content(answer.question.body["en"].upcase)
      end

      it "shows the percentage" do
        expect(page).to have_content("50%")
      end

      it "has a detail link" do
        expect(page).to have_link("Show answers")
      end

      it "has an export link" do
        expect(page).to have_link("Export")
      end

      context "when no short answer exist" do
        let(:first_type) { "long_answer" }

        it "shows session token" do
          expect(page).not_to have_content(answer.body)
          expect(page).to have_content(answer.session_token)
          expect(page).to have_content("USER IDENTIFIER")
        end
      end
    end
  end
end
