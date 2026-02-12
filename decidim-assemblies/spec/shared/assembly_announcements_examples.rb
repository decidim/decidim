# frozen_string_literal: true

shared_examples "manage assemblies announcements" do
  let(:announcement_assembly) { assembly }
  let!(:content_block) do
    create(
      :content_block,
      organization:,
      scope_name: :assembly_homepage,
      manifest_name: :announcement,
      scoped_resource_id: announcement_assembly.id,
      published_at: Time.current
    )
  end

  def fill_announcement_editor(values)
    if page.has_css?("#content_block-settings--announcement-tabs")
      fill_in_i18n_editor(
        :content_block_settings_announcement,
        "#content_block-settings--announcement-tabs",
        values
      )
    else
      fill_in_editor("content_block_settings_announcement_en", with: values.fetch(:en))
    end
  end

  it "can customize a general announcement for the assembly" do
    visit decidim_admin_assemblies.edit_assembly_landing_page_content_block_path(announcement_assembly, content_block)

    fill_announcement_editor(
      en: "An important announcement",
      es: "Un aviso muy importante",
      ca: "Un avís molt important"
    )

    click_on "Update"

    expect(page).to have_content("Active content blocks")
    visit decidim_admin_assemblies.assemblies_path

    if defined?(parent_assembly) && !parent_assembly.nil?
      within "tr", text: translated(parent_assembly.title) do
        click_on "Assemblies"
      end
    end

    new_window = window_opened_by do
      within "tr", text: translated(announcement_assembly.title) do
        find("button[data-controller='dropdown']").click
        click_on "Preview"
      end
    end

    page.within_window(new_window) do
      expect(page).to have_content("An important announcement")
    end
  end
end
