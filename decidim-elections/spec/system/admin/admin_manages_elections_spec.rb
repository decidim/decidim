# frozen_string_literal: true

require "spec_helper"

describe "Admin manages elections" do
  include_context "when managing a component as an admin"

  let(:manifest_name) { "elections" }
  let(:participatory_space_path) do
    decidim_admin_participatory_processes.edit_participatory_process_path(participatory_process)
  end

  let(:participatory_space_manifests) { [participatory_process.manifest.name] }
  let!(:election) { create(:election, component: current_component) }
  let!(:published_election) { create(:election, :published, component: current_component) }
  let!(:finished_election) { create(:election, :published, :finished, component: current_component) }
  let!(:ongoing_election) { create(:election, :published, :ongoing, component: current_component) }
  let!(:results_published_election) { create(:election, :published, :results_published, component: current_component) }

  let(:attributes) { attributes_for(:election, component: current_component) }
  let(:start_time) { Time.current.change(day: 10, hour: 12, min: 50) }
  let(:end_time) { Time.current.change(day: 12, hour: 12, min: 50) }

  before do
    visit_component_admin
  end

  it "lists elections" do
    expect(page).to have_content("Elections")
    expect(page).to have_content(translated(election.title))
    expect(page).to have_content(translated(published_election.title))
    expect(page).to have_content(translated(finished_election.title))
    expect(page).to have_content(translated(ongoing_election.title))
    expect(page).to have_content(translated(results_published_election.title))
    expect(page).to have_content("Unpublished")
    expect(page).to have_content("Scheduled")
    expect(page).to have_content("Published results")
    expect(page).to have_content("Ongoing")
    expect(page).to have_content("Finished")
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
end
