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
          select scope.name, from: :proposal_scope_id

          find("*[type=submit]").click
        end

        expect(page).to have_content("successfully")
        expect(page).to have_content("Oriol for president")
        expect(page).to have_content("He will solve everything")
        expect(page).to have_content(category.name["en"])
        expect(page).to have_content(scope.name)
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

  context "when a proposal has comments" do
    let(:proposal) { create(:proposal, feature: feature)}
    let(:author) { create(:user, :confirmed, organization: feature.organization)}
    let!(:comments) { create_list(:comment, 3, commentable: proposal) }

    before do
      click_link "Processes"
      click_link participatory_process.title["en"]
      click_link "Proposals"
    end

    it "shows the comments" do
      click_link proposal.title

      comments.each do |comment| 
        expect(page).to have_content(comment.body)
      end
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

    context "when filtering" do
      context "by origin 'official'" do
        it "lists the filtered proposals" do
          create(:proposal, feature: feature, scope: scope, decidim_author_id: nil)

          visit decidim_proposals.proposals_path(:proposals, feature_id: feature, participatory_process_id: participatory_process)
          within ".filters" do
            choose "Official"
          end

          expect(page).to have_css(".card--proposal", count: 1)
          expect(page).to have_content("1 PROPOSAL")
        end
      end

      context "by origin 'citizenship'" do
        it "lists the filtered proposals" do
          visit decidim_proposals.proposals_path(:proposals, feature_id: feature, participatory_process_id: participatory_process)
          within ".filters" do
            choose "Citizenship"
          end

          expect(page).to have_css(".card--proposal", count: proposals.size)
          expect(page).to have_content("#{proposals.size} PROPOSALS")
        end
      end
    end
  end
end
