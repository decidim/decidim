# frozen_string_literal: true

require "spec_helper"

describe "Admin manages election steps", :vcr, :billy, :slow, type: :system do
  let(:manifest_name) { "elections" }

  include_context "when mocking the bulletin board in the browser"

  include_context "when managing a component as an admin" do
    let(:admin_component_organization_traits) { [:secure_context] }
  end

  before do
    election
    login_as user, scope: :user
    visit_component_admin
  end

  describe "setup an election" do
    let!(:election) { create :election, :ready_for_setup, component: current_component }

    it "performs the action successfully" do
      within find("tr", text: translated(election.title)) do
        page.find(".action-icon--manage-steps").click
      end

      within "form.create_election" do
        expect(page).to have_content("The election has at least 1 question.")
        expect(page).to have_content("Each question has at least 2 answers.")
        expect(page).to have_content("All the questions have a correct value for maximum of answers.")
        expect(page).to have_content("The election is published.")
        expect(page).to have_content("The setup is being done at least 3 hours before the election starts.")
        expect(page).to have_content("The participatory space has at least 2 trustees with public key.")
        expect(page).to have_content("has a public key", minimum: 2)

        click_button "Setup election"
      end

      expect(page).to have_admin_callout("successfully")

      within ".form.created" do
        expect(page).to have_content("Election created")
        expect(page).to have_content("Start the key ceremony")
      end
    end
  end

  describe "start the key ceremony" do
    let!(:election) { create :election, :bb_test, :created, component: current_component }

    it "performs the action successfully" do
      within find("tr", text: translated(election.title)) do
        page.find(".action-icon--manage-steps").click
      end

      within ".form.created" do
        expect(page).to have_content("Trustees")

        click_button "Start the key ceremony"
      end

      expect(page).to have_admin_callout("successfully")

      within ".form.created" do
        expect(page).to have_content("Processing...")
      end

      within ".content.key_ceremony" do
        expect(page).to have_content("Key ceremony")
      end
    end
  end

  describe "view key ceremony step" do
    let!(:election) { create :election, :key_ceremony, component: current_component }

    it "shows the step information" do
      within find("tr", text: translated(election.title)) do
        page.find(".action-icon--manage-steps").click
      end

      within ".content.key_ceremony" do
        expect(page).to have_content("Key ceremony")
      end
    end
  end

  describe "start the voting period" do
    let!(:election) { create :election, :bb_test, :key_ceremony_ended, component: current_component }

    it "performs the action successfully" do
      within find("tr", text: translated(election.title)) do
        page.find(".action-icon--manage-steps").click
      end

      within ".form.key_ceremony_ended" do
        expect(page).to have_content("The election will start soon.")

        click_button "Start voting period"
      end

      expect(page).to have_admin_callout("successfully")

      within ".form.key_ceremony_ended" do
        expect(page).to have_content("Processing...")
      end

      within ".form.vote" do
        expect(page).to have_content("Vote period")
      end
    end
  end

  describe "end the voting period" do
    let!(:election) { create :election, :bb_test, :vote, :finished, component: current_component }

    it "performs the action successfully" do
      within find("tr", text: translated(election.title)) do
        page.find(".action-icon--manage-steps").click
      end

      within ".form.vote" do
        expect(page).to have_content("The election has ended.")

        click_button "End voting period"
      end

      expect(page).to have_admin_callout("successfully")

      within ".form.vote" do
        expect(page).to have_content("Processing...")
      end

      within ".form.vote_ended" do
        expect(page).to have_content("Start tally")
      end
    end
  end

  describe "start the tally" do
    let!(:election) { create :election, :bb_test, :vote_ended, component: current_component }

    it "performs the action successfully" do
      within find("tr", text: translated(election.title)) do
        page.find(".action-icon--manage-steps").click
      end

      within ".form.vote_ended" do
        expect(page).to have_content("Vote period ended")

        click_button "Start tally"
      end

      expect(page).to have_admin_callout("successfully")

      within ".form.vote_ended" do
        expect(page).to have_content("Processing...")
      end

      within ".content.tally" do
        expect(page).to have_content("Tally")
      end
    end
  end
end
