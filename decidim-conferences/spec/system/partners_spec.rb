# frozen_string_literal: true

require "spec_helper"

describe "Conference partners", type: :system do
  let(:organization) { create(:organization) }
  let(:conference) { create(:conference, organization:) }
  let(:current_participatory_space) { conference }

  before do
    switch_to_host(organization.host)
  end

  context "when there are no partners" do
    it "the menu link is not shown" do
      visit decidim_conferences.conference_path(conference)
      expect(page).to have_no_content("PARTNERS")
    end
  end

  context "when there are partners" do
    let!(:main_promotors) { create_list(:partner, 2, :main_promotor, conference:) }
    let!(:collaborators) { create_list(:partner, 2, :collaborator, conference:) }
    let!(:partners) { main_promotors + collaborators }

    it "the menu link is shown" do
      visit decidim_conferences.conference_path(conference)

      within ".process-nav" do
        expect(page).to have_content("PARTNERS")
        click_link "Partners"
      end
    end

    it "lists all conference partners" do
      visit decidim_conferences.conference_path(conference)

      within "#conference-partners" do
        expect(page).to have_content("ORGANIZERS")
        expect(page).to have_content("PARTNERS")
        expect(page).to have_selector("#conference-partners .partner-box", count: 4)

        partners.each do |partner|
          expect(page).to have_content(partner.name)
        end
      end
    end
  end
end
