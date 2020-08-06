# frozen_string_literal: true

require "spec_helper"

describe "Explore elections", :slow, type: :system do
  include_context "with a component"
  let(:manifest_name) { "elections" }

  let(:elections_count) { 5 }
  let!(:elections) do
    create_list(:election, elections_count, :complete, :published, :ongoing, component: component)
  end

  describe "index" do
    context "with only one election" do
      before do
        Decidim::Elections::Election.destroy_all
      end

      let!(:single_elections) { create_list(:election, 1, :complete, :published, :ongoing, component: component) }

      it "redirects to the only election" do
        visit_component

        expect(page).to have_content("Voting ends on")
        expect(page).not_to have_content("All elections")
      end
    end

    context "with many elections" do
      it "shows all elections for the given process" do
        visit_component
        expect(page).to have_selector(".card--election", count: elections_count)

        elections.each do |election|
          expect(page).to have_content(translated(election.title))
        end
      end
    end

    context "when filtering" do
      it "allows searching by text" do
        visit_component
        within ".filters" do
          fill_in "filter[search_text]", with: translated(elections.first.title)

          # The form should be auto-submitted when filter box is filled up, but
          # somehow it's not happening. So we workaround that be explicitly
          # clicking on "Search" until we find out why.
          find(".icon--magnifying-glass").click
        end

        expect(page).to have_css("#elections-count", text: "1 ELECTION")
        expect(page).to have_css(".card--election", count: 1)
        expect(page).to have_content(translated(elections.first.title))
      end

      it "allows filtering by state" do
        finished_election = create(:election, :complete, :published, :finished, component: component)
        upcoming_election = create(:election, :complete, :published, :upcoming, component: component)
        visit_component

        within ".state_check_boxes_tree_filter" do
          uncheck "All"
          check "Finished"
        end

        expect(page).to have_css(".card--election", count: 1)
        expect(page).to have_content(translated(finished_election.title))

        within ".state_check_boxes_tree_filter" do
          uncheck "All"
          check "Active"
        end

        expect(page).to have_css(".card--election", count: 5)

        within ".state_check_boxes_tree_filter" do
          uncheck "All"
          check "Upcoming"
        end

        expect(page).to have_css(".card--election", count: 1)
        expect(page).to have_content(translated(upcoming_election.title))

        within ".state_check_boxes_tree_filter" do
          uncheck "All"
        end

        expect(page).to have_css(".card--election", count: 7)
      end
    end

    context "when paginating" do
      before do
        Decidim::Elections::Election.destroy_all
      end

      let!(:collection) { create_list :election, collection_size, :complete, :published, :ongoing, component: component }
      let!(:resource_selector) { ".card--election" }

      it_behaves_like "a paginated resource"
    end
  end
end
