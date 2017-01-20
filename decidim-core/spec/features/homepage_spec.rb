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

    describe "statistics" do
      let!(:users) { create_list(:user, 4, :confirmed, organization: organization) }
      let!(:participatory_process){
          create_list(
            :participatory_process,
            2,
            :published,
            organization: organization,
            description: { en: "Description", ca: "Descripció", es: "Descripción" },
            short_description: { en: "Short description", ca: "Descripció curta", es: "Descripción corta" }
          )
      }

      context "when organization show_statistics attribute is false" do
        let(:organization) { create(:organization, show_statistics: false) }
        it "should not show the statistics block" do
          expect(page).to_not have_content("Current state of #{organization.name}")
        end
      end
      
      context "when organization show_statistics attribute is true" do
        let(:organization) { create(:organization, show_statistics: true) }

        before do
          visit current_path
        end
        
        it "should show the statistics block" do
          within "#statistics" do
            expect(page).to have_content("Current state of #{organization.name}")
            expect(page).to have_content("PROCESSES")
            expect(page).to have_content("USERS")
          end
        end

        it "should have the correct values for the statistics" do
          within ".users-count" do
            expect(page).to have_content("4")
          end     
          within ".processes-count" do
            expect(page).to have_content("2")
          end 
        end
      end
    end
  end
end
