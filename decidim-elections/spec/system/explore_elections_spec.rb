# frozen_string_literal: true

require "spec_helper"

describe "Explore elections", :slow, type: :system do
  include_context "with a component"
  let(:manifest_name) { "elections" }

  let(:elections_count) { 5 }
  let!(:elections) do
    create_list(:election, elections_count, :complete, :published, :ongoing, component:)
  end

  describe "index" do
    context "with only one election" do
      before do
        Decidim::Elections::Election.destroy_all
      end

      let!(:single_elections) { create_list(:election, 1, :complete, :published, :ongoing, component:) }

      it "redirects to the only election" do
        visit_component

        expect(page).to have_content("Active voting until")
        expect(page).not_to have_content("All elections")
        expect(page).to have_content("These are the questions you will find in the voting process")
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
          fill_in "filter[search_text_cont]", with: translated(elections.first.title)

          # The form should be auto-submitted when filter box is filled up, but
          # somehow it's not happening. So we workaround that be explicitly
          # clicking on "Search" until we find out why.
          find(".icon--magnifying-glass").click
        end

        expect(page).to have_css("#elections-count", text: "1 ELECTION")
        expect(page).to have_css(".card--election", count: 1)
        expect(page).to have_content(translated(elections.first.title))
      end

      it "allows filtering by date" do
        finished_election = create(:election, :complete, :published, :finished, component:)
        upcoming_election = create(:election, :complete, :published, :upcoming, component:)
        visit_component

        within ".with_any_date_check_boxes_tree_filter" do
          uncheck "All"
          check "Finished"
        end

        expect(page).to have_css(".card--election", count: 1)
        expect(page).to have_content(translated(finished_election.title))

        within ".with_any_date_check_boxes_tree_filter" do
          uncheck "All"
          check "Active"
        end

        expect(page).to have_css(".card--election", count: 5)

        within ".with_any_date_check_boxes_tree_filter" do
          uncheck "All"
          check "Upcoming"
        end

        expect(page).to have_css(".card--election", count: 1)
        expect(page).to have_content(translated(upcoming_election.title))

        within ".with_any_date_check_boxes_tree_filter" do
          uncheck "All"
        end

        expect(page).to have_css(".card--election", count: 7)
      end
    end

    context "when no active or upcoming elections scheduled" do
      before do
        Decidim::Elections::Election.destroy_all
      end

      let!(:finished_elections) do
        create_list(:election, elections_count, :complete, :published, :finished, component:)
      end

      it "shows the correct warning" do
        visit_component
        within ".callout" do
          expect(page).to have_content("no scheduled elections")
        end
      end
    end

    context "when no elections is given" do
      before do
        Decidim::Elections::Election.destroy_all
      end

      it "shows the correct warning" do
        visit_component
        within ".callout" do
          expect(page).to have_content("any election scheduled")
        end
      end
    end

    context "when paginating" do
      before do
        Decidim::Elections::Election.destroy_all
      end

      let!(:collection) { create_list :election, collection_size, :complete, :published, :ongoing, component: }
      let!(:resource_selector) { ".card--election" }

      it_behaves_like "a paginated resource"
    end
  end

  describe "show" do
    let(:elections_count) { 1 }
    let(:election) { elections.first }
    let(:question) { election.questions.first }
    let(:image) { create(:attachment, :with_image, attached_to: election) }

    before do
      election.update!(attachments: [image])
      visit resource_locator(election).path
    end

    it "shows all election info" do
      expect(page).to have_i18n_content(election.title)
      expect(page).to have_i18n_content(election.description)
      expect(page).to have_content(election.end_time.day)
    end

    it "shows accordion with questions and answers" do
      expect(page).to have_css(".accordion-item", count: election.questions.count)
      expect(page).not_to have_css(".accordion-content")

      within ".accordion-item:first-child" do
        click_link translated(question.title)
        expect(page).to have_css("li", count: question.answers.count)
      end
    end

    context "with attached photos" do
      it "shows the image" do
        expect(page).to have_xpath("//img[@src=\"#{image.url}\"]")
      end
    end
  end

  context "with results" do
    let(:election) { create(:election, :published, :results_published, component:) }
    let(:question) { create :question, :with_votes, election: }

    before do
      election.update!(questions: [question])
      visit resource_locator(election).path
    end

    it "shows result information" do
      expect(page).to have_i18n_content(question.title)
      expect(page).to have_content("ELECTION RESULTS")
    end
  end
end
