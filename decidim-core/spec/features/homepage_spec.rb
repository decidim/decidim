# frozen_string_literal: true
require "spec_helper"

describe "Homepage", type: :feature do
  context "when there's an organization" do
    let(:organization) { create(:organization) }

    before do
      switch_to_host(organization.host)
      visit decidim.root_path
    end

    it "welcomes the user" do
      expect(page).to have_content(organization.name)
    end

    context "when there are static pages" do
      let!(:static_pages) { create_list(:static_page, 3, organization: organization) }
      before do
        visit current_path
      end

      it "includes links to them" do
        within ".main-footer" do
          expect(page).to have_css("li a", count: 3)
          static_pages.each do |static_page|
            expect(page).to have_content(static_page.title["en"])
          end
        end

        static_page = static_pages.first
        click_link static_page.title["en"]
        expect(page).to have_i18n_content(static_page.title, locale: "en")

        expect(page).to have_i18n_content(static_page.content, locale: "en")
      end
    end
  end
end
