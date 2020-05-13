# frozen_string_literal: true

require "spec_helper"

shared_examples_for "delete questionnaires" do
  it "deletes a questionnaire" do
    visit manage_component_path(component)

    within "#questionnaire_#{questionnaire.id}" do
      accept_confirm do
        click_link "Delete"
      end
    end

    expect(page).to have_admin_callout("successfully")

    expect(page).to have_no_content(translated(questionnaire.title))
  end

  context "with answers" do
    it "cannot delete questionnaires" do
      create :answer, questionnaire: questionnaire

      visit manage_component_path(component)

      expect(page).to have_no_selector(".action-icon--remove")
    end
  end
end
