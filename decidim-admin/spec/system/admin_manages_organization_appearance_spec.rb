# frozen_string_literal: true

require "spec_helper"

describe "Admin manages organization", type: :system do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization:) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  describe "edit" do
    context "when the HTML header snippets feature is enabled" do
      before do
        allow(Decidim).to receive(:enable_html_header_snippets).and_return(true)
      end

      it "shows the HTML header snippet form field" do
        visit decidim_admin.edit_organization_appearance_path

        expect(page).to have_field(:organization_header_snippets)
      end
    end

    context "when the HTML header snippets feature is disabled" do
      before do
        allow(Decidim).to receive(:enable_html_header_snippets).and_return(false)
      end

      it "does not show the HTML header snippet form field" do
        visit decidim_admin.edit_organization_appearance_path

        expect(page).to have_no_field(:organization_header_snippets)
      end
    end

    it "updates the values from the form" do
      visit decidim_admin.edit_organization_appearance_path

      fill_in_i18n_editor :organization_description,
                          "#organization-description-tabs",
                          en: "My own super description",
                          es: "Mi gran descripción",
                          ca: "La meva gran descripció"

      fill_in "Official organization URL", with: "http://www.example.com"

      dynamically_attach_file(:organization_logo, Decidim::Dev.asset("city2.jpeg"))
      dynamically_attach_file(:organization_favicon, Decidim::Dev.asset("logo.png"), remove_before: true) do
        expect(page).to have_content("Has to be a square image")
      end
      dynamically_attach_file(:organization_official_img_header, Decidim::Dev.asset("city2.jpeg"), remove_before: true)
      dynamically_attach_file(:organization_official_img_footer, Decidim::Dev.asset("city3.jpeg"), remove_before: true)

      fill_in :organization_theme_color, with: "#a0a0a0"

      click_button "Update"

      expect(page).to have_content("updated successfully")

      within "#minimap" do
        expect(page.all("img").count).to eq(4)
      end
    end

    it "updates the value of the theme-color meta tag" do
      color = "#a0a0a0"

      visit decidim_admin.edit_organization_appearance_path

      fill_in :organization_theme_color, with: color
      click_button "Update"
      visit decidim.root_path
      meta_tag = page.find 'meta[name="theme-color"]', visible: false

      expect(meta_tag[:content]).to eq(color)
    end
  end
end
