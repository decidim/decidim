# frozen_string_literal: true

shared_examples "manage announcements" do
  it "customize a general announcement for the component" do
    visit edit_component_path(current_component)

    fill_in_i18n_editor(
      :component_settings_announcement,
      "#global-settings-announcement-tabs",
      en: "An important announcement",
      es: "Un aviso muy importante",
      ca: "Un avís molt important"
    )

    click_button "Update"

    visit main_component_path(current_component)

    within ".notification.js-announcement" do
      expect(page).to have_content("An important announcement")
    end
  end

  context "when the general announcement is set" do
    before do
      current_component.update!(
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
      visit edit_component_path(current_component)
      step_id = current_component.participatory_space.steps.first.id

      fill_in_i18n_editor(
        :"component_step_settings_#{step_id}_announcement",
        "#step-#{step_id}-settings-announcement-tabs",
        en: "An announcement for this step",
        es: "Un aviso para esta fase",
        ca: "Un avís per a aquesta fase"
      )

      click_button "Update"

      visit main_component_path(current_component)

      within ".notification.js-announcement" do
        expect(page).to have_no_content("An important announcement")
        expect(page).to have_content("An announcement for this step")
      end
    end
  end
end
