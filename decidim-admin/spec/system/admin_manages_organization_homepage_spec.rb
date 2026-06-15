# frozen_string_literal: true

require "spec_helper"

describe "Admin manages organization homepage" do
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

      within ".edit_content_blocks" do
        click_on "Add content block"
        within "#add-content-block-dropdown" do
          find("a", text: "Hero image").click
        end
      end
      sleep 1

      expect(Decidim::ContentBlock.count).to eq 1
    end
  end

  context "when editing a persisted content block" do
    let!(:content_block) { create(:content_block, organization:, manifest_name: :hero, scope_name: :homepage) }

    it "updates the settings of the content block" do
      visit decidim_admin.edit_organization_homepage_content_block_path(content_block)

      fill_in(
        :content_block_settings_welcome_text_en,
        with: "Custom welcome text!"
      )

      click_on "Update"
      sleep 1
      visit decidim.root_path
      expect(page).to have_content("Custom welcome text!")
    end

    it "updates the images of the content block" do
      visit decidim_admin.edit_organization_homepage_content_block_path(content_block)

      dynamically_attach_file(:content_block_images_background_image, Decidim::Dev.asset("city2.jpeg"))

      click_on "Update"
      sleep 1
      visit decidim.root_path
      expect(page.html).to include("city2.jpeg")
    end

    context "and edits highlighted content banner settings" do
      let!(:content_block) { create(:content_block, organization:, manifest_name: :highlighted_content_banner, scope_name: :homepage) }

      it "updates the settings of the content block" do
        visit decidim_admin.edit_organization_homepage_content_block_path(content_block)

        fill_in(:content_block_settings_title_en, with: "Custom title text!")
        fill_in(:content_block_settings_action_button_title_en, with: "Custom action title!")
        fill_in(:content_block_settings_action_button_subtitle_en, with: "Custom action subtitle!")
        fill_in(:content_block_settings_action_button_url, with: "http://example.org")

        fill_in_i18n_editor :content_block_settings_short_description, "#content_block-settings--short_description-tabs",
                            en: "<p>The Short description</p>"

        click_on "Update"
        sleep 1
        visit decidim.root_path
        expect(page).to have_text("Custom title text!")
        expect(page).to have_text("The Short description")
        expect(page).to have_link("Custom action subtitle!", href: "http://example.org")
      end

      it "updates the images of the content block" do
        visit decidim_admin.edit_organization_homepage_content_block_path(content_block)

        fill_in(:content_block_settings_title_en, with: "Custom title text!")
        fill_in(:content_block_settings_action_button_title_en, with: "Custom action title!")
        fill_in(:content_block_settings_action_button_subtitle_en, with: "Custom action subtitle!")
        fill_in(:content_block_settings_action_button_url, with: "http://example.org")

        fill_in_i18n_editor :content_block_settings_short_description, "#content_block-settings--short_description-tabs",
                            en: "<p>The Short description</p>"

        dynamically_attach_file(:content_block_images_background_image, Decidim::Dev.asset("city2.jpeg"))

        click_on "Update"

        sleep 1
        visit decidim.root_path
        expect(page.html).to include("city2.jpeg")
      end

      it "displays the 'Resolution is too large' error message when image is invalid" do
        visit decidim_admin.edit_organization_homepage_content_block_path(content_block)

        fill_in(:content_block_settings_title_en, with: "Custom title text!")
        fill_in(:content_block_settings_action_button_title_en, with: "Custom action title!")
        fill_in(:content_block_settings_action_button_subtitle_en, with: "Custom action subtitle!")
        fill_in(:content_block_settings_action_button_url, with: "http://example.org")

        dynamically_attach_file(:content_block_images_background_image, Decidim::Dev.asset("8001x4000.png"))

        click_on "Update"

        expect(page).to have_text("File resolution is too large")
      end

      it "displays validation errors when required fields are empty" do
        visit decidim_admin.edit_organization_homepage_content_block_path(content_block)

        click_on "Update"

        expect(page).to have_text("There is an error in this field.")
      end
    end

    context "and edits html settings" do
      let!(:content_block) { create(:content_block, organization:, manifest_name: :html, scope_name: :homepage) }

      it "updates the settings of the content block" do
        visit decidim_admin.edit_organization_homepage_content_block_path(content_block)

        fill_in(:content_block_settings_html_content_en, with: "Custom HTML text!")
        click_on "Update"
        sleep 1
        visit decidim.root_path
        expect(page).to have_text("Custom HTML text!")
      end
    end
  end

  context "when loading non-existing content blocks" do
    let!(:unpublished_block) { create(:content_block, organization:, scope_name: :homepage, published_at: nil) }
    let!(:published_block) { create(:content_block, organization:, scope_name: :homepage) }

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
