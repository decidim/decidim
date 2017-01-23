# frozen_string_literal: true
require "spec_helper"

describe "Proposals", type: :feature do
  include_context "feature"
  let(:manifest_name) { "proposals" }

  let!(:proposals) { create_list(:proposal, 3, feature: feature) }
  let!(:category) { create :category, participatory_process: participatory_process }
  let!(:scope) { create :scope, organization: organization }
  let!(:user) { create :user, :confirmed, organization: organization }

  before do
    visit_feature
  end

  context "creating a new proposal" do
    context "when the user is logged in" do
      before do
        login_as user, scope: :user
        visit_feature      
      end

      it "creates a new proposal" do
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
      visit_feature
      click_link official_proposal.title
      expect(page).to have_content("Official proposal")
    end
  end

  context "when a proposal has comments" do
    let(:proposal) { create(:proposal, feature: feature)}
    let(:author) { create(:user, :confirmed, organization: feature.organization)}
    let!(:comments) { create_list(:comment, 3, commentable: proposal) }

    it "shows the comments" do
      visit_feature
      click_link proposal.title

      comments.each do |comment| 
        expect(page).to have_content(comment.body)
      end
    end
  end

  context "when a proposal has been linked in a meeting" do
    let(:proposal) { create(:proposal, feature: feature)}
    let(:meeting_feature) do
      create(:feature, manifest_name: :meetings, participatory_process: proposal.feature.participatory_process)
    end
    let(:meeting) { create(:meeting, feature: meeting_feature) }

    before do
      meeting.link_resources([proposal], "proposals_from_meeting")
    end

    it "shows related meetings" do
      visit_feature
      click_link proposal.title

      expect(page).to have_i18n_content(meeting.title)
    end
  end

  context "listing proposals in a participatory process" do
    it "lists all the proposals" do
      expect(page).to have_css(".card--proposal", count: 3)
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
        create_list(:proposal, 17, feature: feature)
        visit_feature
      end

      it "paginates them" do
        expect(page).to have_css(".card--proposal", count: 12)

        find(".pagination-next a").click

        expect(page).to have_css(".card--proposal", count: 8)
      end
    end

    context "when filtering" do
      context "by origin 'official'" do
        it "lists the filtered proposals" do
          create(:proposal, feature: feature, scope: scope, decidim_author_id: nil)
          visit_feature

          within ".filters" do
            choose "Official"
          end

          expect(page).to have_css(".card--proposal", count: 1)
          expect(page).to have_content("1 PROPOSAL")
        end
      end

      context "by origin 'citizenship'" do
        it "lists the filtered proposals" do
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
