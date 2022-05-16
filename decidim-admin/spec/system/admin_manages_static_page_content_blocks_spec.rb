# frozen_string_literal: true

require "spec_helper"

describe "Admin manages static page content blocks", type: :system do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization: organization) }
  let!(:tos_page) { Decidim::StaticPage.find_by(slug: "terms-and-conditions", organization: organization) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  context "when editing a non-persisted content block" do
    it "creates the content block to the db before editing it" do
      visit decidim_admin.edit_static_page_path(tos_page)

      expect(Decidim::ContentBlock.count).to eq 0

      within ".js-list-availables" do
        within find("li", text: "Summary") do
          find("svg.icon--pencil").click
        end
      end

      expect(Decidim::ContentBlock.count).to eq 1
    end
  end

  context "when editing a persisted content block" do
    let!(:content_block) { create :content_block, organization: organization, manifest_name: :summary, scope_name: :static_page, scoped_resource_id: tos_page.id }

    it "updates the settings of the content block" do
      visit decidim_admin.edit_static_page_content_block_path(:summary, static_page_id: tos_page.id)

      fill_in_i18n_editor :content_block_settings_summary,
                          "#content_block-settings--summary-tabs",
                          en: "<p>Custom privacy policy summary text!</p>"

      click_button "Update"
      visit decidim.page_path(tos_page)
      expect(page).to have_content("Custom privacy policy summary text!")
    end
  end
end
