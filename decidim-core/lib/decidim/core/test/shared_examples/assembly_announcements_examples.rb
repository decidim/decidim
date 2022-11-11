# frozen_string_literal: true

shared_examples "manage assemblies announcements" do
  it "can customize a general announcement for the assembly" do
    click_link "Configure"

    fill_in_i18n_editor(
      :assembly_announcement,
      "#assembly-announcement-tabs",
      en: "An important announcement",
      es: "Un aviso muy importante",
      ca: "Un avís molt important"
    )

    within ".edit_assembly" do
      find("*[type=submit]").click
    end

    expect(page).to have_admin_callout("successfully")
    visit decidim_admin_assemblies.assemblies_path

    if defined?(parent_assembly) && !parent_assembly.nil?
      within find("tr", text: translated(parent_assembly.title)) do
        click_link "Assemblies"
      end
    end

    within "tr", text: translated(assembly.title) do
      click_link "Preview"
    end

    expect(page).to have_content("An important announcement")
  end
end
