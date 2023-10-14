# frozen_string_literal: true

shared_examples "manage processes announcements" do
  let!(:participatory_process) { create(:participatory_process, :with_content_blocks, organization:, blocks_manifests: [:announcement]) }

  it "can customize a general announcement for the process" do
    within find("tr", text: translated(participatory_process.title)) do
      click_link translated(participatory_process.title)
    end

    within_admin_sidebar_menu do
      click_link "About this process"
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

    new_window = window_opened_by { page.find("tr", text: translated(participatory_process.title)).click_link("Preview") }

    page.within_window(new_window) do
      expect(page).to have_content("An important announcement")
    end
  end
end
