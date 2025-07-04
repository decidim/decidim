# frozen_string_literal: true

require "spec_helper"

describe "Dashboard" do
  let(:manifest_name) { "elections" }
  let(:participatory_process) { create(:participatory_process, organization:) }
  let(:current_component) { create(:component, participatory_space: participatory_process, manifest_name: "elections") }
  let!(:election) { create(:election, :with_token_csv_census, component: current_component, published_at:) }
  let!(:questions) { create_list(:election_question, 3, election:) }
  let(:published_at) { Time.current }

  include_context "when managing a component as an admin"

  before do
    visit election_dashboard_path
  end

  context "when the election is published" do
    it "does not show publish button" do
      expect(page).to have_no_link("Publish")
    end

    it "can edit only election description" do
      expect(page).to have_link("Main")
      expect(page).to have_no_link("Questions")
      expect(page).to have_no_link("Census")

      click_on "Main"
      # expect(page).to have_field("election[title_en]", with: translated(election.title), disabled: true)
    end
  end

  context "when the election is not published" do
    let(:published_at) { nil }

    it "shows publish button" do
      expect(page).to have_content("Publish")
    end

    it "can edit the main election settings" do
      expect(page).to have_content("Main")
      expect(page).to have_link("Edit", href: %r{/admin/.*/elections/\d+/edit\z})
    end

    it "can edit the election questions" do
      expect(page).to have_content("Questions")
      expect(page).to have_link("Edit", href: %r{/admin/.*/elections/\d+/edit_questions\z})
    end

    it "can edit the census" do
      expect(page).to have_content("Census")
      expect(page).to have_link("Edit", href: %r{/admin/.*/elections/\d+/census\z})
      expect(all("table.table-list tbody tr").count).to eq(3)

      emails = election.voters.map { |v| v.data["email"] }
      emails.each do |email|
        expect(page).to have_content(email)
      end
    end
  end

  context "when the election with a manual start" do
    let!(:election) { create(:election, :with_token_csv_census, component: current_component, start_at:, published_at:) }
    let(:start_at) { nil }

    context "and the election is not started" do
      it "shows the election scheduled status" do
        expect(page).to have_content("Scheduled")
        expect(page).to have_button("Start election")
        expect(page).to have_content("There are no results yet.")
      end
    end

    context "and the election is started" do
      let(:start_at) { 1.day.ago }

      it "shows the election as ongoing" do
        expect(page).to have_content("Ongoing")
        expect(page).to have_button("End election")
      end
    end
  end

  context "when the election with autostart" do
    let!(:election) { create(:election, :with_token_csv_census, component: current_component, start_at:, published_at:) }
    let(:start_at) { 1.day.from_now }

    it "shows the election scheduled status" do
      expect(page).to have_content("Scheduled")
    end

    it "does not show the start election button" do
      expect(page).to have_no_button("Start election")
    end

    it "shows the election start_at date" do
      expected_date = start_at.strftime("%b %d, %Y, %-I:%M %p")
      expect(page).to have_content("Start time: #{expected_date}")
    end
  end

  context "when results availability is set to real_time" do
    let!(:election) { create(:election, :with_token_csv_census, component: current_component, start_at:, results_availability: "real_time", published_at:) }

    context "and the election is not started" do
      let(:start_at) { 1.day.from_now }

      it "shows the election scheduled status" do
        expect(page).to have_content("Scheduled")
      end

      it "shows the results message" do
        expect(page).to have_content("There are no results yet.")
      end
    end

    context "and the election is started" do
      let(:start_at) { 1.day.ago }

      it "shows the election as ongoing" do
        expect(page).to have_content("Ongoing")
        expect(page).to have_button("End election")
      end

      it "shows the results message" do
        expect(page).to have_content("Results")
        expect(page).to have_no_content("There are no results yet.")
        expect(page).to have_no_content("Publish results")
      end
    end
  end

  context "when results availability is set to per_question" do
    let!(:election) { create(:election, :with_token_csv_census, component: current_component, start_at:, results_availability: "per_question", published_at:) }

    context "and the election is not started" do
      let(:start_at) { 1.day.from_now }

      it "shows the election scheduled status" do
        expect(page).to have_content("Scheduled")
      end

      it "shows the results message" do
        expect(page).to have_content("There are no results yet.")
      end
    end

    context "and the election is started" do
      let(:start_at) { 1.minute.ago }

      it "shows the election as ongoing" do
        expect(page).to have_content("Ongoing")
        expect(page).to have_button("End election")
      end

      it "shows the results message" do
        expect(page).to have_content("Results")
        expect(page).to have_no_content("There are no results yet.")
        expect(page).to have_button("Publish results", count: 0, disabled: false)
        expect(page).to have_button("Publish results", count: election.questions.size, disabled: true)
        expect(page).to have_button("Enable voting", count: 3, disabled: false)
      end

      context "when the first question is published and voted" do
        before do
          question = election.questions.first

          within("#question_#{question&.id}") do
            click_on "Enable voting"
            click_on "Publish results"
          end
        end

        it "marks the first question as published and enables voting on the second" do
          first_question = election.questions.first
          second_question = election.questions.second

          within("#question_#{first_question&.id}") do
            expect(page).to have_content("Published results")
            expect(page).to have_no_button("Enable voting")
            expect(page).to have_no_button("Publish results")
          end

          within("#question_#{second_question.id}") do
            expect(page).to have_button("Enable voting", disabled: false)
            expect(page).to have_button("Publish results", disabled: true)
          end

          third_question = election.questions.third
          within("#question_#{third_question.id}") do
            expect(page).to have_button("Enable voting", disabled: false)
          end
        end
      end
    end
  end

  context "when results availability is set to after_end" do
    let!(:election) { create(:election, :with_token_csv_census, component: current_component, start_at:, results_availability: "after_end", published_at:) }

    context "and the election is not started" do
      let(:start_at) { 1.day.from_now }

      it "shows the election scheduled status" do
        expect(page).to have_content("Scheduled")
      end

      it "shows the results message" do
        expect(page).to have_content("There are no results yet.")
      end
    end

    context "and the election is started" do
      let(:start_at) { 1.day.ago }

      it "shows the election as ongoing" do
        expect(page).to have_content("Ongoing")
        expect(page).to have_button("End election")
      end

      it "shows the results message" do
        expect(page).to have_content("Results")
        expect(page).to have_no_content("There are no results yet.")
        expect(page).to have_button("Publish results", count: 1, disabled: true)
      end
    end

    context "and the election is ended" do
      let(:start_at) { 2.days.ago }

      before do
        election.end_at = 1.day.ago
        election.save!
        visit election_dashboard_path
      end

      it "shows the results message" do
        expect(page).to have_content("Results")
        expect(page).to have_no_content("There are no results yet.")
        expect(page).to have_button("Publish results", count: 1, disabled: false)
      end
    end
  end

  context "when the election has published results" do
    let!(:election) { create(:election, :with_token_csv_census, component: current_component, end_at:, published_at:, published_results_at:) }
    let(:end_at) { 1.day.ago }
    let(:published_results_at) { 1.hour.ago }

    it "shows the published results status" do
      expect(page).to have_content("Published results")
      expect(page).to have_button("Publish results", count: 1, disabled: true)
    end
  end

  private

  def election_dashboard_path
    Decidim::EngineRouter.admin_proxy(component).dashboard_election_path(election)
  end
end
