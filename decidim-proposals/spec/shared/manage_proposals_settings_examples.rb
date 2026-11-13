# frozen_string_literal: true

shared_examples "manage settings" do
  let(:rich_text_editor_enabled) { true }
  let(:organization) { create(:organization, rich_text_editor_in_public_views: rich_text_editor_enabled) }

  before do
    within "#admin-sidebar-menu-settings" do
      click_on "Components"
    end

    within "tr", text: translated(component.name) do
      find("button[data-controller='dropdown']").click
      click_on "Configure"
    end
  end

  context "when rich text editor is enabled" do
    it "shows the rich text editor in the body template setting" do
      within ".new_proposal_body_template_container" do
        page.scroll_to(find(".editor-preview"))

        # Scrolling makes the preview intersect the viewport, which triggers the
        # lazy initialization of the editor and hides the preview. Wait for the
        # editor to be mounted instead of asserting on the preview.
        expect(page).to have_css(".ProseMirror")
      end
      expect(page).to have_text("New proposal body template")
    end
  end

  context "when rich text editor is disabled" do
    let(:rich_text_editor_enabled) { false }

    it "does not show the rich text editor in the body template setting" do
      within ".new_proposal_body_template_container" do
        expect(page).to have_no_css(".editor-toolbar")
      end
    end
  end
end
