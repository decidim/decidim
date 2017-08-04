# frozen_string_literal: true

shared_examples "manage processes announcements" do
  let!(:participatory_process) { create(:participatory_process, organization: organization) }

  it "customize an general announcement for the process" do
    click_link translated(participatory_process.title)

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

    within ".callout-wrapper" do
      expect(page).to have_content("successfully")
    end

    visit decidim_admin_participatory_processes.participatory_processes_path

    within "tr", text: translated(participatory_process.title) do
      page.find("a.action-icon--preview").click
    end

    expect(page).to have_content("An important announcement")
  end
end
