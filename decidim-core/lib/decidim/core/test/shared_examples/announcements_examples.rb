# -*- coding: utf-8 -*-
# frozen_string_literal: true

RSpec.shared_examples "manage announcements" do
  it "customize an general announcement for the feature" do
    visit edit_feature_path(current_feature)

    fill_in_i18n_editor(
      :feature_settings_announcement,
      "#feature-settings-announcement-tabs",
      en: "An important announcement",
      es: "Un aviso muy importante",
      ca: "Un avís molt important"
    )

    click_button "Update"

    visit main_feature_path(current_feature)

    within ".callout.secondary" do
      expect(page).to have_content("An important announcement")
    end
  end
end
