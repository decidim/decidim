# frozen_string_literal: true

shared_examples "manage processes announcements" do
  let(:participatory_process) { create(:participatory_process, :with_content_blocks, organization:, blocks_manifests: [], announcement: {}) }
  let!(:content_block) do
    create(
      :content_block,
      organization:,
      scope_name: :participatory_process_homepage,
      manifest_name: :announcement,
      scoped_resource_id: participatory_process.id,
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

  def clear_announcement_editor(locales)
    if page.has_css?("#content_block-settings--announcement-tabs")
      clear_i18n_editor(
        :content_block_settings_announcement,
        "#content_block-settings--announcement-tabs",
        locales
      )
    else
      clear_editor("content_block_settings_announcement_en")
    end
  end

  it "can customize a general announcement for the process" do
    visit decidim_admin_participatory_processes.edit_participatory_process_landing_page_content_block_path(participatory_process, content_block)

    fill_announcement_editor(
      en: "An important announcement",
      es: "Un aviso muy importante",
      ca: "Un avís molt important"
    )

    click_on "Update"

    expect(page).to have_content("Active content blocks")

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
    visit decidim_admin_participatory_processes.edit_participatory_process_landing_page_content_block_path(participatory_process, content_block)
    clear_announcement_editor([:en, :es, :ca])

    click_on "Update"

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
