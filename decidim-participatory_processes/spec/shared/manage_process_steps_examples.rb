# frozen_string_literal: true

shared_examples "manage process steps examples" do
  let(:active) { false }
  let!(:process_step) do
    create(
      :participatory_process_step,
      participatory_process:,
      active:
    )
  end

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_participatory_processes.edit_participatory_process_path(participatory_process)
    within_admin_sidebar_menu do
      click_link "Phases"
    end
  end

  it_behaves_like "having a rich text editor for field", ".tabs-content[data-tabs-content='participatory_process_step-description-tabs']", "full" do
    before { click_link "New phase" }
  end

  it "creates a new participatory_process" do
    click_link "New phase"

    fill_in_i18n(
      :participatory_process_step_title,
      "#participatory_process_step-title-tabs",
      en: "My participatory process step",
      es: "Mi fase de proceso participativo",
      ca: "La meva fase de procés participatiu"
    )
    fill_in_i18n_editor(
      :participatory_process_step_description,
      "#participatory_process_step-description-tabs",
      en: "A longer description",
      es: "Descripción más larga",
      ca: "Descripció més llarga"
    )

    find("#participatory_process_step_start_date_date").click

    fill_in_datepicker :participatory_process_step_start_date_date, with: Time.new.utc.strftime("%d.%m.%Y")
    fill_in_timepicker :participatory_process_step_start_date_time, with: Time.new.utc.strftime("%H:%M")
    fill_in_datepicker :participatory_process_step_end_date_date, with: (Time.new.utc + 2.days).strftime("%d.%m.%Y")
    fill_in_timepicker :participatory_process_step_end_date_time, with: (Time.new.utc + 4.hours).strftime("%H:%M")

    within ".new_participatory_process_step" do
      click_button "Create"
    end

    expect(page).to have_admin_callout("successfully")

    within "#steps table" do
      expect(page).to have_content("My participatory process step")
      expect(page).to have_content("#{Time.new.utc.day},")
      expect(page).to have_content("#{(Time.new.utc + 2.days).day},")
    end
  end

  it "updates a participatory_process_step" do
    within "#steps" do
      within find("tr", text: translated(process_step.title)) do
        click_link "Edit"
      end
    end

    within ".edit_participatory_process_step" do
      fill_in_i18n(
        :participatory_process_step_title,
        "#participatory_process_step-title-tabs",
        en: "My new title",
        es: "Mi nuevo título",
        ca: "El meu nou títol"
      )

      find("*[type=submit]").click
    end

    expect(page).to have_admin_callout("successfully")

    within "#steps table" do
      expect(page).to have_content("My new title")
      click_link("My new title")
    end
  end

  context "when deleting a participatory process step" do
    let!(:process_step2) { create(:participatory_process_step, participatory_process:) }

    before do
      visit current_path
    end

    it "deletes a participatory_process_step" do
      within find("tr", text: translated(process_step2.title)) do
        accept_confirm { click_link "Delete" }
      end

      expect(page).to have_admin_callout("successfully")

      within "#steps table" do
        expect(page).not_to have_content(translated(process_step2.title))
      end
    end
  end

  context "when activating a step" do
    it "activates a step" do
      within find("tr", text: translated(process_step.title)) do
        click_link "Activate"
      end

      within find("tr", text: translated(process_step.title)) do
        expect(page).not_to have_content("Activate")
      end
    end
  end
end
