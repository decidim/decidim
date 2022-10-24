# frozen_string_literal: true

require "spec_helper"

describe "Admin manages organization homepage", type: :system do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization:) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  context "when editing a non-persisted content block" do
    it "creates the content block to the db before editing it" do
      visit decidim_admin.edit_organization_homepage_path

      expect(Decidim::ContentBlock.count).to eq 0

      within ".js-list-availables" do
        within find("li", text: "Hero image") do
          find("svg.icon--pencil").click
        end
      end

      expect(Decidim::ContentBlock.count).to eq 1
    end
  end

  context "when editing a persisted content block" do
    let!(:content_block) { create :content_block, organization:, manifest_name: :hero, scope_name: :homepage }

    it "updates the settings of the content block" do
      visit decidim_admin.edit_organization_homepage_content_block_path(:hero)

      fill_in(
        :content_block_settings_welcome_text_en,
        with: "Custom welcome text!"
      )

      click_button "Update"
      visit decidim.root_path
      expect(page).to have_content("Custom welcome text!")
    end

    it "updates the images of the content block" do
      visit decidim_admin.edit_organization_homepage_content_block_path(:hero)

      dynamically_attach_file(:content_block_images_background_image, Decidim::Dev.asset("city2.jpeg"))

      click_button "Update"
      visit decidim.root_path
      expect(page.html).to include("city2.jpeg")
    end
  end

  context "when loading non-existing content blocks" do
    let!(:unpublished_block) { create :content_block, organization:, scope_name: :homepage, published_at: nil }
    let!(:published_block) { create :content_block, organization:, scope_name: :homepage }

    before do
      # We do this to simulate content blocks from some modules that have been
      # uninstalled from the app.
      unpublished_block.update(manifest_name: :fake_name)
      published_block.update(manifest_name: :fake_name)
    end

    it "loads the page as expected" do
      visit decidim_admin.edit_organization_homepage_path

      expect(page).to have_text("Active content blocks")
    end
  end
end
