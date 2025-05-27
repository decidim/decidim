# frozen_string_literal: true

require "spec_helper"

describe "Admin manages static page content blocks" do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization:) }
  let!(:tos_page) { Decidim::StaticPage.find_by(slug: "terms-of-service", organization:) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  context "when editing a non-persisted content block" do
    it "creates the content block to the db before editing it" do
      visit decidim_admin.edit_static_page_path(tos_page, locale: I18n.locale)

      expect(Decidim::ContentBlock.count).to eq 0

      within ".edit_content_blocks" do
        click_on "Add content block"
        within ".add-components" do
          find("a", text: "Summary").click
        end
      end

      expect(Decidim::ContentBlock.count).to eq 1
    end
  end

  context "when including multiple blocks with the same manifest" do
    let(:number_of_content_blocks) { Faker::Number.within(range: 2..5) }

    it "creates all the content blocks" do
      visit decidim_admin.edit_static_page_path(tos_page)
      expect do
        number_of_content_blocks.times do
          within ".edit_content_blocks" do
            click_on "Add content block"
            within ".add-components" do
              find("a", text: "Section").click
            end
          end
        end
      end.to change(Decidim::ContentBlock, :count).by number_of_content_blocks
    end
  end

  context "when the page has multiple content blocks with the same manifest" do
    let(:content1) { Faker::Lorem.sentence }
    let(:content2) { Faker::Lorem.sentence }
    let!(:content_block1) { create(:content_block, organization:, manifest_name: :section, scope_name: :static_page, scoped_resource_id: tos_page.id, settings: { content_en: content1 }) }
    let!(:content_block2) { create(:content_block, organization:, manifest_name: :section, scope_name: :static_page, scoped_resource_id: tos_page.id, settings: { content_en: content2 }) }

    it "shows all of them" do
      visit decidim.page_path(tos_page, locale: I18n.locale)
      expect(page).to have_content(content1)
      expect(page).to have_content(content2)
    end
  end

  context "when deleting content block" do
    let(:content) { Faker::Lorem.sentence }
    let!(:content_block) { create(:content_block, organization:, manifest_name: :section, scope_name: :static_page, scoped_resource_id: tos_page.id, settings: { content_en: content }) }

    it "the content block is no further visible on the page" do
      visit decidim_admin.edit_static_page_path(tos_page)

      within ".edit_content_blocks" do
        within first("ul.js-list-actives li") do
          accept_confirm { find("a[data-method='delete']").click }
        end
      end

      expect(page).to have_content("Content block successfully deleted")

      visit decidim.page_path(tos_page, locale: I18n.locale)
      expect(page).to have_no_content(content)
    end
  end

  context "when editing a persisted content block" do
    let!(:content_block) { create(:content_block, organization:, manifest_name: :summary, scope_name: :static_page, scoped_resource_id: tos_page.id) }

    it "updates the settings of the content block" do
      visit decidim_admin.edit_static_page_content_block_path(content_block, static_page_id: tos_page.slug)

      fill_in_i18n_editor :content_block_settings_summary,
                          "#content_block-settings--summary-tabs",
                          en: "<p>Custom privacy policy summary text!</p>"

      click_on "Update"
      visit decidim.page_path(tos_page, locale: I18n.locale)
      expect(page).to have_content("Custom privacy policy summary text!")

      logout
      visit decidim.new_user_registration_path
      expect(page).to have_content("Custom privacy policy summary text!")
    end
  end
end
