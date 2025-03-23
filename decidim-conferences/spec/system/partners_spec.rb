# frozen_string_literal: true

require "spec_helper"

describe "Conference partners" do
  let(:organization) { create(:organization) }
  let(:conference) { create(:conference, organization:) }
  let(:current_participatory_space) { conference }

  before do
    switch_to_host(organization.host)
  end

  context "when there are no partners" do
    it "the menu link is not shown" do
      visit decidim_conferences.conference_path(conference, locale: I18n.locale)
      expect(page).to have_no_content("Partners")
    end
  end

  context "when there are partners" do
    let!(:main_promotors) { create_list(:partner, 2, :main_promotor, conference:) }
    let!(:collaborators) { create_list(:partner, 2, :collaborator, conference:) }

    it "the menu link is shown" do
      visit decidim_conferences.conference_path(conference, locale: I18n.locale)

      within "aside .conference__nav-container" do
        expect(page).to have_content("Partners")
        click_on "Partners"
      end
    end

    it "lists all conference partners" do
      visit decidim_conferences.conference_path(conference, locale: I18n.locale)

      within "#conference-partners-main_promotor" do
        expect(page).to have_content("Organizers")
        expect(page).to have_css(".conference__grid-item", count: 2)

        main_promotors.each do |collaborator|
          expect(page).to have_content(collaborator.name)
        end
      end

      within "#conference-partners-collaborator" do
        expect(page).to have_content("Partners")
        expect(page).to have_css(".conference__grid-item", count: 2)

        collaborators.each do |collaborator|
          expect(page).to have_content(collaborator.name)
        end
      end
    end
  end
end
