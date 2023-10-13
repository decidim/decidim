# frozen_string_literal: true

shared_examples "manage settings" do
  include Decidim::SanitizeHelper
  let(:rich_text_editor_enabled) { true }
  let(:organization) { create(:organization, rich_text_editor_in_public_views: rich_text_editor_enabled) }
  let(:body_template) { "<p>test</p>" }
  before do
    component.settings[:new_proposal_body_template] = body_template
    component.save!
    within_admin_menu do
      click_link "Components"
    end
    click_link "Configure"
  end

  context "when rich text editor is enabled" do
    it "shows the rich text editor in the body template setting" do
      within ".new_proposal_body_template_container" do
        expect(page).to have_css(".editor-toolbar")
      end
      expect(page).to have_content("New proposal body template")
    end
  end

  context "when rich text editor is disabled" do
    let(:rich_text_editor_enabled) { false }

    it "does not show the rich text editor in the body template setting" do
      within ".new_proposal_body_template_container" do
        expect(page).not_to have_css(".editor-toolbar")
      end
    end

    it "does not display string tags in the body template" do
      expect(decidim_sanitize(body_template, strip_tags: true)).not_to include("<p>")
      expect(decidim_sanitize(body_template, strip_tags: true)).not_to include("</p>")
    end
  end
end
