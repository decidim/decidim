# frozen_string_literal: true

require "spec_helper"

describe "Admin manages organization" do
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

    context "when the color picker is used" do
      it "changes the color on click" do
        visit decidim_admin.edit_organization_appearance_path

        expect(page).to have_css(".color-picker")
        find(".color-picker summary").click
        selector = find_by_id("primary-selector")

        selector.find("div[data-value='#40a8bf']").click
        expect(find_by_id("preview-primary", visible: :all).value).to eq "#40a8bf"
        expect(find_by_id("preview-secondary", visible: :all).value).to eq "#bf40a8"
        expect(find_by_id("preview-tertiary", visible: :all).value).to eq "#a8bf40"

        selector.find("div[data-value='#bf408c']").click
        expect(find_by_id("preview-primary", visible: :all).value).to eq "#bf408c"
        expect(find_by_id("preview-secondary", visible: :all).value).to eq "#8cbf40"
        expect(find_by_id("preview-tertiary", visible: :all).value).to eq "#408cbf"
      end
    end

    it "updates the values from the form" do
      visit decidim_admin.edit_organization_appearance_path

      fill_in "Official organization URL", with: "http://www.example.com"

      dynamically_attach_file(:organization_logo, Decidim::Dev.asset("city2.jpeg"))
      dynamically_attach_file(:organization_favicon, Decidim::Dev.asset("logo.png"), remove_before: true) do
        expect(page).to have_content("Has to be a square image")
      end
      dynamically_attach_file(:organization_official_img_footer, Decidim::Dev.asset("city3.jpeg"), remove_before: true)

      click_on "Update"

      expect(page).to have_content("updated successfully")

      within "#minimap" do
        expect(page.all("img").count).to eq(3)
      end
    end
  end
end
