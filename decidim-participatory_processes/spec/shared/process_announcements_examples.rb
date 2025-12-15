# frozen_string_literal: true

shared_examples "manage processes announcements" do
  let!(:participatory_process) { create(:participatory_process, :with_content_blocks, organization:, blocks_manifests: [:announcement], announcement: {}) }

  it "can customize a general announcement for the process" do
    within "tr", text: translated(participatory_process.title) do
      click_on translated(participatory_process.title)
    end

    within_admin_sidebar_menu do
      click_on "About this process"
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

    new_window = window_opened_by do
      within("tr", text: translated(participatory_process.title)) do
        find("button[data-controller='dropdown']").click
        click_on "Preview"
      end
    end

    page.within_window(new_window) do
      expect(page).to have_content("An important announcement")
    end
  end

  it "remove announcement element if announcement body is empty" do
    within "tr", text: translated(participatory_process.title) do
      click_on translated(participatory_process.title)
    end

    within_admin_sidebar_menu do
      click_on "About this process"
    end

    find_by_id("participatory_process-announcement-tabs").click
    send_keys("T")
    send_keys(:backspace)

    within ".edit_participatory_process" do
      find("*[type=submit]").click
    end

    expect(page).to have_admin_callout("successfully")

    visit decidim_admin_participatory_processes.participatory_processes_path

    new_window = window_opened_by do
      within("tr", text: translated(participatory_process.title)) do
        find("button[data-controller='dropdown']").click
        click_on "Preview"
      end
    end

    page.within_window(new_window) do
      expect(page).to have_no_css(".flash")
      expect(page).to have_no_css(".flash__message")
      expect(page).to have_no_css(".announcement")
    end
  end
end
