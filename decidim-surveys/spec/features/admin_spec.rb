# coding: utf-8
# frozen_string_literal: true
require "spec_helper"

describe "Edit a survey", type: :feature do
  include_context "feature admin"
  let(:feature) { create(:surveys_feature, participatory_process: participatory_process) }
  let(:manifest_name) { feature.manifest_name }
  
  before do
    create(:survey, feature: feature)
    visit_feature_admin
  end

  it "updates the survey" do
    new_description = {
      en: "<p>New description</p>",
      ca: "<p>Nova descripció</p>",
      es: "<p>Nueva descripción</p>"
    }

    within "form.edit_survey" do
      fill_in_i18n_editor(:survey_description, "#description-tabs", new_description)
      find("*[type=submit]").click
    end

    within ".callout-wrapper" do
      expect(page).to have_content("successfully")
    end

    visit_feature

    expect(page).to have_content("New description")
  end
end
