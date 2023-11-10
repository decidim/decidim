# frozen_string_literal: true

require "spec_helper"

describe "Explore elections", :slow do
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
        within "#elections" do
          expect(page).to have_css("[id^=elections]", count: elections_count)
        end

        elections.each do |election|
          expect(page).to have_content(translated(election.title))
        end
      end
    end

    context "when filtering" do
      it "allows searching by text" do
        visit_component

        within "[data-filters]" do
          fill_in "filter[search_text_cont]", with: translated(elections.first.title)

          within "div.filter-search" do
            click_button
          end
        end

        expect(page).to have_content("1 election")

        within "#elections" do
          expect(page).to have_css("[id^=elections]", count: 1)
          expect(page).to have_content(translated(elections.first.title))
        end
      end

      it "allows filtering by date" do
        finished_election = create(:election, :complete, :published, :finished, component:)
        upcoming_election = create(:election, :complete, :published, :upcoming, component:)
        visit_component

        within "#panel-dropdown-menu-date" do
          uncheck "Active"
          check "Finished"
        end

        within "#elections" do
          expect(page).to have_css("[id^=elections]", count: 1)
          expect(page).to have_content(translated(finished_election.title))
        end

        within "#panel-dropdown-menu-date" do
          uncheck "Finished"
          check "Active"
        end

        within "#elections" do
          expect(page).to have_css("[id^=elections]", count: 5)
        end

        within "#panel-dropdown-menu-date" do
          uncheck "Active"
          check "Upcoming"
        end

        within "#elections" do
          expect(page).to have_css("[id^=elections]", count: 1)
          expect(page).to have_content(translated(upcoming_election.title))
        end

        within "#panel-dropdown-menu-date" do
          check "All"
          uncheck "All"
        end

        within "#elections" do
          expect(page).to have_css("[id^=elections]", count: 7)
        end
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
        within ".flash" do
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
        within ".flash" do
          expect(page).to have_content("any election scheduled")
        end
      end
    end

    context "when paginating" do
      before do
        Decidim::Elections::Election.destroy_all
      end

      let!(:collection) { create_list(:election, collection_size, :complete, :published, :ongoing, component:) }
      let!(:resource_selector) { "[id^=elections__election]" }

      it_behaves_like "a paginated resource"
    end
  end

  describe "show" do
    let(:elections_count) { 1 }
    let(:description) { Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title } }
    let(:election) { create(:election, :complete, :published, :ongoing, component:, description:) }
    let(:question) { election.questions.first }
    let(:image) { create(:attachment, :with_image, attached_to: election) }

    before do
      election.update!(attachments: [image])
      visit resource_locator(election).path
    end

    it_behaves_like "has embedded video in description", :description

    it "shows all election info" do
      expect(page).to have_i18n_content(election.title)
      expect(page).to have_i18n_content(election.description)
      expect(page).to have_content(election.end_time.day)
    end

    it "shows accordion with questions and answers" do
      expect(page).to have_css("#accordion-preview li", count: election.questions.count)
      expect(page).not_to have_css("[id^='accordion-panel']")

      within "#accordion-preview li", match: :first do
        click_button translated(question.title)
        expect(page).to have_css("li", count: question.answers.count)
      end
    end

    context "with attached photos" do
      it "shows the image" do
        expect(page).to have_selector("img[src*=\"city.jpeg\"]", count: 1)
      end
    end
  end

  context "with results" do
    let(:election) { create(:election, :published, :results_published, component:) }
    let(:question) { create(:question, :with_votes, election:) }

    before do
      election.update!(questions: [question])
      visit resource_locator(election).path
    end

    it "shows result information" do
      expect(page).to have_i18n_content(question.title)
      expect(page).to have_content("Election results")
    end
  end
end
