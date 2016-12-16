# frozen_string_literal: true
require "spec_helper"

describe "Proposals", type: :feature do
  let(:feature) { create(:proposal_feature) }
  let(:organization) { feature.organization }
  let(:participatory_process) { feature.participatory_process }
  let!(:proposals) { create_list(:proposal, 3, feature: feature) }

  before do
    switch_to_host(organization.host)
    visit decidim.root_path
  end

  context "listing proposals in a participatory process" do
    before do
      click_link "Processes"
      click_link participatory_process.title["en"]
      click_link "Proposals"
    end

    it "lists all the proposals" do
      expect(page).to have_css(".card--proposal", 3)
    end

    it "allows viewing a single proposal" do
      proposal = proposals.first

      click_link proposal.title

      expect(page).to have_content(proposal.title)
      expect(page).to have_content(proposal.body)
      expect(page).to have_content(proposal.author.name)
    end

    context "when there are a lot of proposals" do
      before do
        create_list(:proposal, 20, feature: feature)
        visit current_path
      end

      it "paginates them" do
        expect(page).to have_css(".card--proposal", 12)

        find(".pagination-next a").click

        expect(page).to have_css(".card--proposal", 8)
      end
    end
  end
end
