# frozen_string_literal: true

shared_examples "manage announcements" do
  it "customize a general announcement for the feature" do
    visit edit_feature_path(current_feature)

    fill_in_i18n_editor(
      :feature_settings_announcement,
      "#global-settings-announcement-tabs",
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

  context "when the general announcement is set" do
    before do
      current_feature.update_attributes!(
        settings: {
          announcement: {
            en: "An important announcement",
            es: "Un aviso muy importante",
            ca: "Un avís molt important"
          }
        }
      )
    end

    it "customize an announcement for the current step and it has more priority" do
      visit edit_feature_path(current_feature)

      fill_in_i18n_editor(
        :feature_step_settings_1_announcement,
        "#step-1-settings-announcement-tabs",
        en: "An announcement for this step",
        es: "Un aviso para esta fase",
        ca: "Un avís per a aquesta fase"
      )

      click_button "Update"

      visit main_feature_path(current_feature)

      within ".callout.secondary" do
        expect(page).to have_no_content("An important announcement")
        expect(page).to have_content("An announcement for this step")
      end
    end
  end
end
