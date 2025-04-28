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

  it "displays page title" do
    expect(page).to have_content("Demographic data donation")
  end

  it "hides delete my data button" do
    expect(page).to have_no_button("Delete data")
  end

  context "when collecting data" do
    it "saves the form" do
      expect(page).to have_no_button("Delete data")

      fill_in translated(question.body), with: "My first response"
      check "questionnaire_tos_agreement"

      expect(page).to have_button("Save", class: "button__secondary", disabled: false)
      click_on "Save data"

      within ".success.flash" do
        expect(page).to have_content("successfully")
      end

      expect(page).to have_button("Delete data")
    end

    it "successfully deletes the data" do
      expect(questionnaire.reload).not_to be_responded_by(user)

      fill_in translated(question.body), with: "My first response"
      check "questionnaire_tos_agreement"
      click_on "Save data"

      within ".success.flash" do
        expect(page).to have_content("successfully")
      end
      sleep(1)

      expect(questionnaire.reload).to be_responded_by(user)

      expect(page).to have_button("Delete data")
      click_on("Delete data")

      expect(page).to have_content("All your demographic data will be removed.")
      expect(page).to have_content("Delete data")
      expect(page).to have_button("Cancel")
      expect(page).to have_button("Ok")

      click_on("Ok")

      expect(page).to have_content("Successfully removed your donated data")
      expect(questionnaire.reload).not_to be_responded_by(user)
    end

    it "requires tos to be accepted" do
      fill_in translated(question.body), with: "My first response"

      expect(page).to have_button("Save data", class: "button__secondary", disabled: false)
      click_on "Save data"

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

      expect(page).to have_button("Save data", class: "button__secondary", disabled: true)
    end
  end
end
