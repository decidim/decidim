# frozen_string_literal: true

shared_examples "manage process phases examples" do
  let(:active) { false }
  let!(:process_phase) do
    create(
      :participatory_process_phase,
      participatory_process:,
      active:
    )
  end
  let(:attributes) { attributes_for(:participatory_process_phase, participatory_process:) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_participatory_processes.edit_participatory_process_path(participatory_process)
    within_admin_sidebar_menu do
      click_on "Phases"
    end
  end

  it_behaves_like "having a rich text editor for field", ".tabs-content[data-tabs-content='participatory_process_phase-description-tabs']", "full" do
    before { click_on "New phase" }
  end

  it "creates a new participatory_process", versioning: true do
    click_on "New phase"

    fill_in_i18n(
      :participatory_process_phase_title,
      "#participatory_process_phase-title-tabs",
      **attributes[:title].except("machine_translations")
    )
    fill_in_i18n_editor(
      :participatory_process_phase_description,
      "#participatory_process_phase-description-tabs",
      **attributes[:description].except("machine_translations")
    )

    find_by_id("participatory_process_phase_start_date_date").click

    fill_in_datepicker :participatory_process_phase_start_date_date, with: Time.now.utc.strftime("%d/%m/%Y")
    fill_in_timepicker :participatory_process_phase_start_date_time, with: Time.now.utc.strftime("%H:%M")
    fill_in_datepicker :participatory_process_phase_end_date_date, with: (Time.now.utc + 2.days).strftime("%d/%m/%Y")
    fill_in_timepicker :participatory_process_phase_end_date_time, with: (Time.now.utc + 4.hours).strftime("%H:%M")

    within ".new_participatory_process_phase" do
      click_on "Create"
    end

    expect(page).to have_callout("Participatory process phase successfully created.")

    within "#phases table" do
      expect(page).to have_text(translated(attributes[:title]))
      expect(page).to have_text(Time.now.utc.day)
      expect(page).to have_text((Time.now.utc + 2.days).day)
    end
    visit decidim_admin.root_path
    expect(page).to have_text("created the #{translated(attributes[:title])} phase in")
  end

  it "updates a participatory_process_phase", versioning: true do
    within "#phases" do
      within "tr", text: translated(process_phase.title) do
        find("button[data-controller='dropdown']").click
        click_on "Edit"
      end
    end

    within ".edit_participatory_process_phase" do
      fill_in_i18n(:participatory_process_phase_title, "#participatory_process_phase-title-tabs", **attributes[:title].except("machine_translations"))
      fill_in_i18n_editor(:participatory_process_phase_description, "#participatory_process_phase-description-tabs", **attributes[:description].except("machine_translations"))

      find("*[type=submit]").click
    end

    expect(page).to have_callout("Participatory process phase successfully updated.")

    within "#phases table" do
      expect(page).to have_text(translated(attributes[:title]))
      click_on(translated(attributes[:title]))
    end

    visit decidim_admin.root_path
    expect(page).to have_text("updated the #{translated(attributes[:title])} phase in")
  end

  context "when deleting a participatory process phase" do
    let!(:process_phase2) { create(:participatory_process_phase, participatory_process:) }

    before do
      visit current_path
    end

    it "deletes a participatory_process_phase" do
      within "tr", text: translated(process_phase2.title) do
        find("button[data-controller='dropdown']").click
        accept_confirm { click_on "Delete" }
      end

      expect(page).to have_callout("Participatory process phase successfully deleted.")

      within "#phases table" do
        expect(page).to have_no_text(translated(process_phase2.title))
      end
    end
  end

  context "when activating a phase" do
    it "activates a phase" do
      within "tr", text: translated(process_phase.title) do
        find("button[data-controller='dropdown']").click
        click_on "Activate"
      end

      within "tr", text: translated(process_phase.title) do
        expect(page).to have_no_text("Activate")
      end
    end
  end
end
