# frozen_string_literal: true

require "spec_helper"

describe "Key ceremony", type: :system do
  include Decidim::Elections::FullElectionHelpers
  context "when performing the key ceremony", :slow, download: true do
    include_context "when performing the whole process"

    it "generates backup keys, restores them and creates election keys" do
      setup_election

      download_election_keys(0)
      download_election_keys(1)
      download_election_keys(2)

      complete_key_ceremony(0)
      check_key_ceremony_completed(1)
      check_key_ceremony_completed(2)
    end
  end

  context "when the comunication with bulletin board fails" do
    include_context "when performing the whole process"
    before do
      allow(Decidim::Elections.bulletin_board).to receive(:bulletin_board_server).and_return("http://idontexist.tld/api")
    end

    it "alerts the user about the error" do
      election

      login_as user, scope: :user
      visit_component_admin

      within find("tr", text: translated(election.title)) do
        page.find(".action-icon--manage-steps").click
      end

      click_button "Setup election"

      click_button "Start the key ceremony"

      within "#server-failure" do
        expect(page).to have_content("Something went wrong")
      end
    end
  end
end
