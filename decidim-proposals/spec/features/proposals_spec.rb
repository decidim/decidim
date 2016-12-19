# frozen_string_literal: true
require "spec_helper"

describe "Proposals", type: :feature do
  let(:feature) { create(:proposal_feature) }
  let(:organization) { feature.organization }
  let(:participatory_process) { feature.participatory_process }
  let!(:proposals) { create_list(:proposal, 3, feature: feature) }
  let!(:category) { create :category, participatory_process: participatory_process }
  let!(:scope) { create :scope, organization: organization }
  let!(:user) { create :user, :confirmed, organization: organization }

  before do
    switch_to_host(organization.host)
    visit decidim.root_path
  end

  context "creating a new proposal" do
    context "when the user is logged in" do
      before do
        login_as user, scope: :user
      end

      it "creates a new proposal" do
        click_link "Processes"
        click_link participatory_process.title["en"]
        click_link "Proposals"
        click_link "New proposal"

        within ".new_proposal" do
          fill_in :proposal_title, with: "Oriol for president"
          fill_in :proposal_body, with: "He will solve everything"
          select category.name["en"], from: :proposal_category_id
          select scope.name["en"], from: :proposal_scope_id

          find("*[type=submit]").click
        end

        expect(page).to have_content("successfully")
        expect(page).to have_content("Oriol for president")
        expect(page).to have_content("He will solve everything")
        expect(page).to have_content(category.name["en"])
        expect(page).to have_content(scope.name["en"])
      end
    end
  end

  context "when it is an official proposal" do
    let!(:official_proposal) { create(:proposal, feature: feature, author: nil) }

    it "shows the author as official" do
      click_link "Processes"
      click_link participatory_process.title["en"]
      click_link "Proposals"
      click_link official_proposal.title

      expect(page).to have_content("Official proposal")
    end
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
