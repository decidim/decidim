# frozen_string_literal: true

require "spec_helper"

describe "user submits demographic data" do
  InvisibleCaptcha.honeypots = [:honeypot_id]
  InvisibleCaptcha.visual_honeypots = true

  let(:organization) { create(:organization) }
  let(:user) { create(:user, :confirmed, organization:) }
  let!(:questionnaire_for) { create(:demographic, organization:, collect_data:) }
  let!(:questionnaire) { create(:questionnaire, questionnaire_for:) }
  let!(:question) { create(:questionnaire_question, questionnaire:, position: 0) }
  let!(:collect_data) { true }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user

    visit demographics_engine.demographics_path
  end

  it "displays the warning" do
    expect(page).to have_content(I18n.t("layouts.decidim.shared.layout_center.alert"))
  end

  context "when collecting data" do
    it "saves the form" do
      fill_in translated(question.body), with: "My first response"
      check "questionnaire_tos_agreement"

      expect(page).to have_button("Submit", class: "button__secondary", disabled: false)
      click_on "Submit"

      within ".success.flash" do
        expect(page).to have_content("successfully")
      end
    end

    it "requires tos to be accepted" do
      fill_in translated(question.body), with: "My first response"

      expect(page).to have_button("Submit", class: "button__secondary", disabled: false)
      click_on "Submit"

      expect(page).to have_content("must be accepted")

      within ".alert.flash" do
        expect(page).to have_content("There was a problem responding the form.")
      end
    end
  end

  context "when data collection is disabled" do
    let!(:collect_data) { false }

    it "denies saving the form" do
      fill_in translated(question.body), with: "My first response"
      check "questionnaire_tos_agreement"

      expect(page).to have_button("Submit", class: "button__secondary", disabled: true)
    end
  end
end
