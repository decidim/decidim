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

    click_on "Update"

    expect(page).to have_text "The component was updated successfully"

    visit main_component_path(current_component)

    within page.find("[data-announcement]", match: :first) do
      expect(page).to have_text("An important announcement")
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

    it "customize an announcement for the current phase and it has more priority" do
      visit edit_component_path(current_component)
      phase_id = current_component.participatory_space.phases.first.id

      fill_in_i18n_editor(
        :"component_phase_settings_#{phase_id}_announcement",
        "#step-#{phase_id}-settings-announcement-tabs",
        en: "An announcement for this phase",
        es: "Un aviso para esta fase",
        ca: "Un avís per a aquesta fase"
      )

      click_on "Update"

      expect(page).to have_text "The component was updated successfully"

      visit main_component_path(current_component)

      within page.find("[data-announcement]", match: :first) do
        expect(page).to have_no_text("An important announcement")
        expect(page).to have_text("An announcement for this phase")
      end
    end
  end
end
