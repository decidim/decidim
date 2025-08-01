# frozen_string_literal: true

require "spec_helper"

describe "Admin manages elections" do
  include_context "when managing a component as an admin"

  let(:manifest_name) { "elections" }
  let(:participatory_space_path) do
    decidim_admin_participatory_processes.edit_participatory_process_path(participatory_process)
  end

  let(:participatory_space_manifests) { [participatory_process.manifest.name] }
  let!(:election) { create(:election, census_manifest: :token_csv, component: current_component) }
  let!(:scheduled_election) { create(:election, :published, :scheduled, component: current_component) }
  let!(:published_election) { create(:election, :published, :per_question, :ongoing, :with_internal_users_census, component: current_component) }
  let!(:finished_election) { create(:election, :published, :finished, component: current_component) }
  let!(:ongoing_election) { create(:election, :published, :ongoing, :with_token_csv_census, component: current_component) }
  let!(:published_results_election) { create(:election, :published, :published_results, component: current_component) }

  let(:attributes) { attributes_for(:election, component: current_component) }
  let(:start_time) { 1.day.from_now }
  let(:end_time) { 3.days.from_now }

  before do
    visit_component_admin
  end

  it "lists elections" do
    expect(page).to have_content("Elections")
    expect(page).to have_content(translated(election.title))
    expect(page).to have_content(translated(published_election.title))
    expect(page).to have_content(translated(finished_election.title))
    expect(page).to have_content(translated(ongoing_election.title))
    expect(page).to have_content(translated(published_results_election.title))
    expect(page).to have_content("Unpublished")
    expect(page).to have_content("Scheduled")
    expect(page).to have_content("Ongoing")
    expect(page).to have_content("Finished")
    expect(page).to have_content("Registered participants (dynamic)")
    expect(page).to have_content("Unregistered participants with tokens (fixed)")
    expect(page).to have_content("View deleted elections")
    expect(page).to have_link("New election")
    expect(page).to have_link("View deleted elections")
  end

  it "creates a new election with manual start" do
    click_on "New election"

    within ".new_election" do
      fill_in_i18n(:election_title, "#election-title-tabs", **attributes[:title].except("machine_translations"))
      fill_in_i18n_editor(:election_description, "#election-description-tabs", **attributes[:description].except("machine_translations"))
      fill_in_datepicker :election_end_at_date, with: end_time.strftime("%d/%m/%Y")
      fill_in_timepicker :election_end_at_time, with: end_time.strftime("%H:%M")
      check "Manual start"
      choose "Real time"
    end

    click_on "Save and continue"

    expect(page).to have_admin_callout "Election created successfully"
    expect(page).to have_content("Question must have at least two answers in order go to the next step.")

    visit decidim_admin.root_path
    expect(page).to have_content("created the #{translated(attributes[:title])} election in")
  end

  describe "admin form" do
    before { click_on "New election" }

    it_behaves_like "having a rich text editor", "new_election", "full"
  end

  describe "updating an election" do
    it "updates an election" do
      within "tr", text: translated(election.title) do
        find("button[data-component='dropdown']").click
        click_on "Edit election"
      end

      within ".edit_election" do
        uncheck "Manual start"
        fill_in_datepicker :election_start_at_date, with: start_time.strftime("%d/%m/%Y")
        fill_in_timepicker :election_start_at_time, with: start_time.strftime("%H:%M")
      end

      click_on "Save and continue"

      expect(page).to have_admin_callout "Election updated successfully"
      expect(page).to have_content("Question must have at least two answers in order go to the next step.")
    end
  end

  context "when the election is published" do
    let!(:question1) { create(:election_question, :with_response_options, election: published_election) }
    let!(:question2) { create(:election_question, :with_response_options, election: published_election) }

    before do
      within "tr", text: translated(published_election.title) do
        find("button[data-component='dropdown']").click
        click_on "Edit election"
      end
    end

    it "allows to edit the description and the image only" do
      within ".edit_election" do
        expect(page).to have_field("election[title_en]", with: translated(published_election.title), disabled: true)
        fill_in_i18n_editor(:election_description, "#election-description-tabs", **attributes[:description].except("machine_translations"))
      end
      dynamically_attach_file(:election_photos, Decidim::Dev.asset("city2.jpeg"))

      click_on "Save and continue"
      expect(page).to have_admin_callout "Election updated successfully"
    end

    it "questions and census cannot be edited" do
      expect(page).to have_link("Main")
      expect(page).to have_no_link("Questions")
      expect(page).to have_no_link("Census")
      expect(page).to have_link("Dashboard")

      click_on "Dashboard"
      expect(page).to have_content("Voting is not yet enabled for any questions.")
      click_on "Enable voting", match: :first
      expect(page).to have_no_content("Voting is not yet enabled for any questions.")
    end
  end

  context "when the election is ongoing" do
    let!(:question1) { create(:election_question, :with_response_options, election: ongoing_election) }
    let!(:question2) { create(:election_question, :with_response_options, election: ongoing_election) }

    before do
      click_on translated(ongoing_election.title)
    end

    it "monitors the election" do
      expect(page).to have_content("Results available after the election ends")
      within "#question_#{question1.id}" do
        expect(page).to have_content(translated(question1.body))
        expect(page).to have_content("0 votes")
        expect(page).to have_content("0.0%")
      end
      create(:election_vote, voter_uid: "user-1", question: question1, response_option: question1.response_options.first)
      create(:election_vote, voter_uid: "user-2", question: question2, response_option: question2.response_options.first)
      create(:election_vote, voter_uid: "user-3", question: question2, response_option: question2.response_options.second)
      create(:election_vote, voter_uid: "user-4", question: question2, response_option: question2.response_options.second)
      # wait for javascript to update the page
      sleep 4
      within "#question_#{question1.id}" do
        expect(page).to have_content("1 vote")
        expect(page).to have_content("100.0%")
      end
      within "#question_#{question2.id}" do
        expect(page).to have_content("1 vote")
        expect(page).to have_content("33.3%")
        expect(page).to have_content("2 votes")
        expect(page).to have_content("66.7%")
      end
    end
  end
end
