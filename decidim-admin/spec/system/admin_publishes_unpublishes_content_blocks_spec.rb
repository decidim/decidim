# frozen_string_literal: true

require "spec_helper"

describe "Admin publishes/unpublishes content blocks" do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization:) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  context "when publishing a content block via admin UI" do
    let!(:hero_block) { create(:content_block, organization:, manifest_name: :hero, scope_name: :homepage, weight: nil, published_at: nil) }

    it "shows published content block on the homepage" do
      visit decidim_admin.edit_organization_homepage_path
      page.refresh

      within ".edit_content_blocks" do
        within ".js-list-available" do
          expect(page).to have_css("li", text: "Hero image")
        end

        first("ul.js-list-available li").drag_to(find("ul.js-list-actives"))
        sleep 2
      end

      expect(hero_block.reload.published_at).not_to be_nil

      visit decidim.root_path
      expect(page).to have_css("[id^=hero]")
    end
  end

  context "when unpublishing a content block via admin UI" do
    let!(:hero_block) { create(:content_block, organization:, manifest_name: :hero, scope_name: :homepage, weight: 1, published_at: Time.current) }
    let!(:extra_block) { create(:content_block, organization:, manifest_name: :sub_hero, scope_name: :homepage, weight: 2, published_at: Time.current) }

    it "does not show unpublished content block on the homepage" do
      visit decidim_admin.edit_organization_homepage_path
      page.refresh

      within ".edit_content_blocks" do
        within ".js-list-actives" do
          expect(page).to have_css("li", text: "Hero image")
        end

        first("ul.js-list-actives li").drag_to(find("ul.js-list-available"))
        sleep 2
      end

      expect(hero_block.reload.published_at).to be_nil

      visit decidim.root_path
      expect(page).to have_no_css("[id^=hero]")
    end
  end
end
