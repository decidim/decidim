# frozen_string_literal: true

require "spec_helper"

describe "Admin editor link target remains" do
  let(:organization) { create(:organization) }
  let(:admin) { create(:user, :admin, :confirmed, organization: organization) }
  let(:participatory_process) { create(:participatory_process, organization: organization) }
  let(:component) { create(:component, manifest_name: "pages", participatory_space: participatory_process) }

  before do
    switch_to_host(organization.host)
    login_as admin, scope: :user
  end

  it "allows editing contents without target automatically changing" do
    visit decidim_admin_participatory_processes.edit_component_path(participatory_process, component)

    within ".global-settings" do
      announcement_editor = first(".editor-container[data-options*='admin']")
      skip "No admin editor found" unless announcement_editor

      # creating initial link in same tab
      editor_input = announcement_editor.find(".editor-input .ProseMirror")
      editor_input.click
      editor_input.send_keys("Test link")
      page.execute_script("window.getSelection().selectAllChildren(arguments[0].firstChild)", editor_input)
      toolbar = announcement_editor.find(".editor-toolbar")
      link_button = toolbar.find("button[data-editor-type='link']")
      link_button.click
      send_keys("https://decidim.org")
    end

    within "[data-dialog][aria-hidden='false']" do
      find("button[data-action='save']").click
    end
    click_button "Update"
    expect(page).to have_content("The component was updated successfully")

    # modifying content
    visit decidim_admin_participatory_processes.edit_component_path(participatory_process, component)
    within ".global-settings" do
      announcement_editor = first(".editor-container[data-options*='admin']")
      skip "No admin editor found" unless announcement_editor
      editor_input = announcement_editor.find(".editor-input .ProseMirror")
      editor_input.click
      editor_input.send_keys(:enter, :enter, :arrow_up, "...more content")
    end
    click_button "Update"
    expect(page).to have_content("The component was updated successfully")

    # checking link is still in same tab
    visit decidim_admin_participatory_processes.edit_component_path(participatory_process, component)
    announcement_editor = first(".editor-container[data-options*='admin']")
    editor_input = announcement_editor.find(".editor-input .ProseMirror")
    editor_input.click
    page.execute_script("window.getSelection().selectAllChildren(arguments[0].firstChild)", editor_input)
    within "[data-linkbubble-actions]" do
      click_button "Edit"
    end
    expect(page).to have_text("Default (same tab)")
  end
end
