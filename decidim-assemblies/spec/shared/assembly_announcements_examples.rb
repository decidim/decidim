# frozen_string_literal: true

shared_examples "manage assemblies announcements" do
  it "can customize a general announcement for the assembly" do
    within("tr", text: translated(assembly.title)) do
      find("button[data-component='dropdown']").click
      click_on "Configure"
    end

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
      within "tr", text: translated(parent_assembly.title) do
        click_on "Assemblies"
      end
    end

    new_window = window_opened_by do
      within "tr", text: translated(assembly.title) do
        find("button[data-component='dropdown']").click
        click_on "Preview"
      end
    end

    page.within_window(new_window) do
      expect(page).to have_content("An important announcement")
    end
  end
end
