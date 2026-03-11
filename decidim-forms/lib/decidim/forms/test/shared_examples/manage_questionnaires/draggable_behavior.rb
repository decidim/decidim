# frozen_string_literal: true

require "spec_helper"

shared_examples_for "manage questionnaire draggable behavior" do
  let!(:question) { create(:questionnaire_question, :title_and_description, questionnaire:) }

  context "when questionnaire has no responses (editable)" do
    it "shows draggable data attributes for questions list" do
      visit_manage_questions

      expect(page).to have_css("[data-draggable-table]")
      expect(page).to have_css("[data-draggable-handle]")
    end

    describe "when hovering over card divider" do
      it "shows resize cursor for editable questions" do
        visit_manage_questions

        within first(".questionnaire-question") do
          expect(page).to have_css(".card-divider.hover\\:cursor-grab")
        end
      end
    end
  end

  context "when questionnaire has responses (not editable)" do
    let!(:response) { create(:response, questionnaire:) }

    it "does not show draggable data attributes for questions list" do
      visit_manage_questions

      expect(page).have_no_css("[data-draggable-table]")
      expect(page).have_no_css("[data-draggable-handle]")
    end

    describe "when hovering over card divider" do
      it "does not show resize cursor for non-editable questions" do
        visit_manage_questions

        within first(".questionnaire-question") do
          expect(page).to have_no_css(".card-divider.hover\\:cursor-grab")
        end
      end
    end
  end

  private

  def visit_manage_questions
    click_on "Questions"
  end
end
