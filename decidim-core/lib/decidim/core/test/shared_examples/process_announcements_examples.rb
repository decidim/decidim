# frozen_string_literal: true

shared_examples "manage processes announcements" do
  let!(:participatory_process) { create(:participatory_process, organization:) }

  it "can customize a general announcement for the process" do
    within find("tr", text: translated(participatory_process.title)) do
      click_link "Configure"
    end

    fill_in_i18n_editor(
      :participatory_process_announcement,
      "#participatory_process-announcement-tabs",
      en: "An important announcement",
      es: "Un aviso muy importante",
      ca: "Un avís molt important"
    )

    within ".edit_participatory_process" do
      find("*[type=submit]").click
    end

    expect(page).to have_admin_callout("successfully")

    visit decidim_admin_participatory_processes.participatory_processes_path

    within "tr", text: translated(participatory_process.title) do
      click_link "Preview"
    end

    expect(page).to have_content("An important announcement")
  end
end
