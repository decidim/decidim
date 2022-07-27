# frozen_string_literal: true

require "spec_helper"
require "decidim/core/test/shared_examples/has_contextual_help"

describe "Votings", type: :system do
  let(:organization) { create(:organization) }

  before do
    switch_to_host(organization.host)
  end

  context "with only one voting in the votings space" do
    let!(:single_voting) { create :voting, :published, organization: }

    before do
      visit decidim_votings.votings_path
    end

    it "redirects to the voting" do
      expect(page).to have_content(translated(single_voting.title))
      expect(page).not_to have_selector("#votings")
    end
  end

  context "with many votings" do
    let!(:votings) { create_list(:voting, 2, :published, organization:) }

    it_behaves_like "shows contextual help" do
      let(:index_path) { decidim_votings.votings_path }
      let(:manifest_name) { :votings }
    end

    context "when ordering by 'Most recent'" do
      let!(:older_voting) do
        create(:voting, :published, organization:, created_at: 1.month.ago)
      end

      let!(:recent_voting) do
        create(:voting, :published, organization:, created_at: Time.now.utc)
      end

      before do
        switch_to_host(organization.host)
      end

      it_behaves_like "editable content for admins" do
        let(:target_path) { visit decidim_votings.votings_path }
      end

      context "when requesting the votings path" do
        before do
          visit decidim_votings.votings_path
        end

        it "lists the votings ordered by created at" do
          within ".order-by" do
            expect(page).to have_selector("ul[data-dropdown-menu$=dropdown-menu]", text: "Random")
            page.find("a", text: "Random").click
            click_link "Most recent"
          end

          expect(page).to have_selector("#votings .card-grid .column:first-child", text: recent_voting.title[:en])
          expect(page).to have_selector("#votings .card-grid .column:last-child", text: older_voting.title[:en])
        end
      end
    end

    context "when ordering by 'Random'" do
      let!(:votings) { create_list(:voting, 2, :published, organization:) }

      before do
        switch_to_host(organization.host)
        visit decidim_votings.votings_path
      end

      it "shows all votings" do
        within ".order-by" do
          expect(page).to have_selector("ul[data-dropdown-menu$=dropdown-menu]", text: "Random")
        end

        expect(page).to have_selector(".card--voting", count: 2)
        expect(page).to have_content(translated(votings.first.title))
        expect(page).to have_content(translated(votings.last.title))
      end
    end

    context "when there are promoted votings" do
      let!(:highlighted_voting) { create(:voting, :published, :promoted, organization:) }
      let!(:other_voting) { create(:voting, :published, organization:) }

      before do
        switch_to_host(organization.host)
        visit decidim_votings.votings_path
      end

      it "lists all the highlighted votings" do
        within "#highlighted-votings" do
          expect(page).to have_content(translated(highlighted_voting.title, locale: :en))
          expect(page).to have_selector(".card--full", count: 1)
        end
      end
    end

    context "when filtering" do
      let!(:voting) { create(:voting, :published, organization:) }

      it "allows searching by text" do
        visit decidim_votings.votings_path
        within ".filters" do
          fill_in "filter[search_text_cont]", with: translated(voting.title)

          # The form should be auto-submitted when filter box is filled up, but
          # somehow it's not happening. So we workaround that be explicitly
          # clicking on "Search" until we find out why.
          find(".icon--magnifying-glass").click
        end

        expect(page).to have_css("#votings-count", text: "1 VOTING")
        expect(page).to have_css(".card--voting", count: 1)
        expect(page).to have_content(translated(voting.title))
      end

      describe "when by different dates" do
        let!(:finished_voting) { create(:voting, :finished, organization:) }
        let!(:upcoming_voting) { create(:voting, :upcoming, organization:) }
        let!(:ongoing_voting) { create(:voting, :ongoing, organization:) }

        before do
          visit decidim_votings.votings_path
        end

        it "allows filtering by finished date" do
          within ".with_any_date_check_boxes_tree_filter" do
            uncheck "All"
            check "Finished"
          end

          expect(page).to have_css(".card--voting", count: 1)
          expect(page).to have_content(translated(finished_voting.title))
        end

        it "allows filtering by active date" do
          within ".with_any_date_check_boxes_tree_filter" do
            uncheck "All"
            check "Active"
          end

          expect(page).to have_css(".card--voting", count: 1)
        end

        it "allows filtering by upcoming date" do
          within ".with_any_date_check_boxes_tree_filter" do
            uncheck "All"
            check "Upcoming"
          end

          expect(page).to have_css(".card--voting", count: 4)
          expect(page).to have_content(translated(upcoming_voting.title))
        end

        it "allows filtering by all date" do
          within ".with_any_date_check_boxes_tree_filter" do
            uncheck "All"
          end

          expect(page).to have_css(".card--voting", count: 6)
        end
      end
    end

    context "when all votings are finished" do
      let!(:votings) { create_list(:voting, 2, :finished, organization:) }

      before do
        switch_to_host(organization.host)
        visit decidim_votings.votings_path
      end

      it "I see an alert" do
        expect(page).to have_content("Currently, there are no scheduled votings, but here you can find the finished votings listed.")
        expect(page).to have_selector(".announcement", count: 1)
      end
    end
  end
end
