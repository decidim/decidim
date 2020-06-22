# frozen_string_literal: true

require "spec_helper"

shared_examples_for "uses questionnaire templates" do |questionnaire_for|
  describe "choose a template" do
    let!(:questionnaire) { create(:questionnaire, :empty, questionnaire_for: send(questionnaire_for)) }

    before do
      visit questionnaire_edit_path
    end

    it "shows the template choosing screen" do
      expect(page).to have_content("Choose template")
    end
  end
end
