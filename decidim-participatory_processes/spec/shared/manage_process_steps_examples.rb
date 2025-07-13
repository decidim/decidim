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
  let(:attributes) { attributes_for(:participatory_process_step, participatory_process:) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_participatory_processes.edit_participatory_process_path(participatory_process)
    within_admin_sidebar_menu do
      click_on "Phases"
    end
  end

  it_behaves_like "having a rich text editor for field", ".tabs-content[data-tabs-content='participatory_process_step-description-tabs']", "full" do
    before { click_on "New phase" }
  end

  it "creates a new participatory_process", versioning: true do
    click_on "New phase"

    fill_in_i18n(
      :participatory_process_step_title,
      "#participatory_process_step-title-tabs",
      **attributes[:title].except("machine_translations")
    )
    fill_in_i18n_editor(
      :participatory_process_step_description,
      "#participatory_process_step-description-tabs",
      **attributes[:description].except("machine_translations")
    )
    fill_in_i18n(:participatory_process_step_cta_text, "#participatory_process_step-cta_text-tabs", **attributes[:cta_text].except("machine_translations"))

    find_by_id("participatory_process_step_start_date_date").click

    fill_in_datepicker :participatory_process_step_start_date_date, with: Time.new.utc.strftime("%d/%m/%Y")
    fill_in_timepicker :participatory_process_step_start_date_time, with: Time.new.utc.strftime("%H:%M")
    fill_in_datepicker :participatory_process_step_end_date_date, with: (Time.new.utc + 2.days).strftime("%d/%m/%Y")
    fill_in_timepicker :participatory_process_step_end_date_time, with: (Time.new.utc + 4.hours).strftime("%H:%M")

    within ".new_participatory_process_step" do
      click_on "Create"
    end

    expect(page).to have_admin_callout("successfully")

    within "#steps table" do
      expect(page).to have_content(translated(attributes[:title]))
      expect(page).to have_content("#{Time.new.utc.day},")
      expect(page).to have_content("#{(Time.new.utc + 2.days).day},")
    end
    visit decidim_admin.root_path
    expect(page).to have_content("created the #{translated(attributes[:title])} phase in")
  end

  it "updates a participatory_process_step", versioning: true do
    within "#steps" do
      within "tr", text: translated(process_step.title) do
        find("button[data-component='dropdown']").click
        click_on "Edit"
      end
    end

    within ".edit_participatory_process_step" do
      fill_in_i18n(:participatory_process_step_title, "#participatory_process_step-title-tabs", **attributes[:title].except("machine_translations"))
      fill_in_i18n_editor(:participatory_process_step_description, "#participatory_process_step-description-tabs", **attributes[:description].except("machine_translations"))
      fill_in_i18n(:participatory_process_step_cta_text, "#participatory_process_step-cta_text-tabs", **attributes[:cta_text].except("machine_translations"))

      find("*[type=submit]").click
    end

    expect(page).to have_admin_callout("successfully")

    within "#steps table" do
      expect(page).to have_content(translated(attributes[:title]))
      click_on(translated(attributes[:title]))
    end

    visit decidim_admin.root_path
    expect(page).to have_content("updated the #{translated(attributes[:title])} phase in")
  end

  context "when deleting a participatory process step" do
    let!(:process_step2) { create(:participatory_process_step, participatory_process:) }

    before do
      visit current_path
    end

    it "deletes a participatory_process_step" do
      within "tr", text: translated(process_step2.title) do
        find("button[data-component='dropdown']").click
        accept_confirm { click_on "Delete" }
      end

      expect(page).to have_admin_callout("successfully")

      within "#steps table" do
        expect(page).to have_no_content(translated(process_step2.title))
      end
    end
  end

  context "when activating a step" do
    it "activates a step" do
      within "tr", text: translated(process_step.title) do
        find("button[data-component='dropdown']").click
        click_on "Activate"
      end

      within "tr", text: translated(process_step.title) do
        expect(page).to have_no_content("Activate")
      end
    end
  end
end
