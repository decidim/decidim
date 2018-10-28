# frozen_string_literal: true

require "spec_helper"

describe "Admin manages organization homepage", type: :system do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization: organization) }

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
    let!(:content_block) { create :content_block, organization: organization, manifest_name: :hero, scope: :homepage }

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

      attach_file(
        :content_block_images_background_image,
        Decidim::Dev.asset("city2.jpeg")
      )

      click_button "Update"
      visit decidim.root_path
      expect(page.html).to include("city2.jpeg")
    end
  end
end
