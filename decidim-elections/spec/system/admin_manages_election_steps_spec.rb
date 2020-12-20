# frozen_string_literal: true

require "spec_helper"

describe "Admin manages election steps", type: :system do
  let(:manifest_name) { "elections" }

  include_context "when managing a component as an admin"

  before do
    election
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit_component_admin
  end

  describe "setup an election", :vcr do
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

      within ".content.key_ceremony" do
        expect(page).to have_content("Key ceremony")
      end
    end
  end

  describe "view key ceremony step" do
    let!(:election) { create :election, :created, component: current_component }

    it "shows the step information" do
      within find("tr", text: translated(election.title)) do
        page.find(".action-icon--manage-steps").click
      end

      within ".content.key_ceremony" do
        expect(page).to have_content("Key ceremony")
      end
    end
  end

  describe "open the ballot box", :vcr do
    let!(:election) { create :election, :ready, :bb_test_election, component: current_component }

    it "performs the action successfully" do
      within find("tr", text: translated(election.title)) do
        page.find(".action-icon--manage-steps").click
      end

      within "form.ready" do
        expect(page).to have_content("The election will start soon.")

        click_button "Open ballot box"
      end

      expect(page).to have_admin_callout("successfully")

      within "form.vote" do
        expect(page).to have_content("Vote period")
      end
    end
  end

  describe "close the ballot box", :vcr do
    let!(:election) { create :election, :vote, :finished, :bb_test_election, component: current_component }

    it "performs the action successfully" do
      within find("tr", text: translated(election.title)) do
        page.find(".action-icon--manage-steps").click
      end

      within "form.vote" do
        expect(page).to have_content("The election has ended.")

        click_button "Close ballot box"
      end

      expect(page).to have_admin_callout("successfully")

      within ".content.tally" do
        expect(page).to have_content("Tally")
      end
    end
  end
end
