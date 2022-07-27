# frozen_string_literal: true

require "spec_helper"

describe "Election log", :slow, type: :system do
  include_context "with a component"

  let(:manifest_name) { "elections" }

  before do
    election
    visit resource_locator(election).path
    click_link "Election log"
  end

  context "when election is not set up" do
    let(:election) { create(:election, :complete, :published, :ready_for_setup, component:) }

    it "shows not started entries" do
      expect(page).to have_content("Election created")
      expect(page).to have_content("The election is not created yet.")
      expect(page).to have_content("The key ceremony has not started yet.")
      expect(page).to have_content("The voting process has not started yet.")
      expect(page).to have_content("The tally process has not started yet.")
      expect(page).to have_content("The results are not published yet.")
      expect(page).not_to have_content("The chained Hash of this message")
    end
  end

  context "when election is created" do
    include_context "with test bulletin board"

    let(:election) { create(:election, :bb_test, :created, component:) }

    it "shows that election is created" do
      expect(page).to have_content("The election got created and is successfully set up on the Bulletin Board.")
      expect(page).to have_content("The key ceremony has not started yet.")
      expect(page).to have_content("The voting process has not started yet.")
      expect(page).to have_content("The tally process has not started yet.")
      expect(page).to have_content("The results are not published yet.")
      expect(page).to have_content("The chained Hash of this message")
    end
  end

  context "when the key ceremony started but is not ended" do
    include_context "with test bulletin board"

    let(:election) { create(:election, :bb_test, :key_ceremony, component:) }

    it "shows that key ceremony has started" do
      expect(page).to have_content("The election got created and is successfully set up on the Bulletin Board.")
      expect(page).to have_content("The key ceremony has started but is not completed yet.")
      expect(page).to have_content("The voting process has not started yet.")
      expect(page).to have_content("The tally process has not started yet.")
      expect(page).to have_content("The results are not published yet.")
      expect(page).to have_content("The chained Hash of this message")
    end
  end

  context "when the key ceremony is finished" do
    include_context "with test bulletin board"

    let(:election) { create(:election, :bb_test, :key_ceremony_ended, component:) }

    it "shows that key ceremony is ended" do
      expect(page).to have_content("The election got created and is successfully set up on the Bulletin Board.")
      expect(page).to have_content("The key ceremony is completed. Every trustee has valid keys and has downloaded the necessary backup keys.")
      expect(page).to have_content("The voting process has not started yet.")
      expect(page).to have_content("The tally process has not started yet.")
      expect(page).to have_content("The results are not published yet.")
      expect(page).to have_content("The chained Hash of this message")
    end
  end

  context "when voting has started" do
    include_context "with test bulletin board"

    let(:election) { create(:election, :bb_test, :vote, component:) }

    it "shows that vote has started" do
      expect(page).to have_content("The election got created and is successfully set up on the Bulletin Board.")
      expect(page).to have_content("The key ceremony is completed. Every trustee has valid keys and has downloaded the necessary backup keys.")
      expect(page).to have_content("The voting process has started.")
      expect(page).to have_content("The tally process has not started yet.")
      expect(page).to have_content("The results are not published yet.")
      expect(page).to have_content("The chained Hash of this message")
    end
  end

  context "when voting has ended" do
    include_context "with test bulletin board"

    let(:election) { create(:election, :bb_test, :vote_ended, component:) }

    it "shows that voting process has ended" do
      expect(page).to have_content("The election got created and is successfully set up on the Bulletin Board.")
      expect(page).to have_content("The key ceremony is completed. Every trustee has valid keys and has downloaded the necessary backup keys.")
      expect(page).to have_content("The voting process is finished.")
      expect(page).to have_content("The tally process has not started yet.")
      expect(page).to have_content("The results are not published yet.")
      expect(page).to have_content("The chained Hash of this message")
    end
  end

  context "when tally has started" do
    include_context "with test bulletin board"

    let(:election) { create(:election, :bb_test, :tally_started, component:) }

    it "shows that tally has started" do
      expect(page).to have_content("The election got created and is successfully set up on the Bulletin Board.")
      expect(page).to have_content("The key ceremony is completed. Every trustee has valid keys and has downloaded the necessary backup keys.")
      expect(page).to have_content("The voting process is finished.")
      expect(page).to have_content("The tally process has started.")
      expect(page).to have_content("The results are not published yet.")
      expect(page).to have_content("The chained Hash of this message")
    end
  end

  context "when tally is completed" do
    include_context "with test bulletin board"

    let(:election) { create(:election, :bb_test, :tally_ended, component:) }

    it "shows that tally has finished" do
      expect(page).to have_content("The election got created and is successfully set up on the Bulletin Board.")
      expect(page).to have_content("The key ceremony is completed. Every trustee has valid keys and has downloaded the necessary backup keys.")
      expect(page).to have_content("The voting process is finished.")
      expect(page).to have_content("The tally process is finished.")
      expect(page).to have_content("The results are not published yet.")
      expect(page).to have_content("The chained Hash of this message")
    end
  end

  context "when results are published" do
    include_context "with test bulletin board"

    let(:election) { create(:election, :bb_test, :results_published, component:) }

    it "shows that results are published" do
      expect(page).to have_content("The election got created and is successfully set up on the Bulletin Board.")
      expect(page).to have_content("The key ceremony is completed. Every trustee has valid keys and has downloaded the necessary backup keys.")
      expect(page).to have_content("The voting process is finished.")
      expect(page).to have_content("The tally process is finished.")
      expect(page).to have_content("The results are published.")
      expect(page).to have_content("The chained Hash of this message")
    end
  end

  describe "verify election" do
    include_context "with test bulletin board"

    context "when election doesn't have correct bb_status" do
      let(:election) { create(:election, :bb_test, :tally_ended, component:) }

      it "does not show instructions to verify election" do
        expect(page).to have_content("Verify Election results")
        expect(page).to have_content("The verifiable election file and SHA256 checksum aren't available yet")
        expect(page).to have_content("NOT READY")
      end
    end

    context "when election has correct bb_status but no verifiable file nor checksum" do
      let(:election) { create(:election, :bb_test, :results_published, component:, verifiable_results_file_hash: nil, verifiable_results_file_url: nil) }

      it "shows instructions to verify election" do
        expect(page).to have_content("VERIFY")
        expect(page).to have_content("Here, you have the option to verify the election.")
      end

      it "shows that file and checksum are not available" do
        expect(page).to have_content("Not yet available")

        within ".card__support" do
          expect(page).not_to have_content("Download")
        end
      end
    end

    context "when election has correct bb_status and verifiable file and checksum" do
      let(:election) { create(:election, :bb_test, :results_published, component:) }

      it "shows instructions to verify election" do
        expect(page).to have_content("VERIFY")
        expect(page).to have_content("Here, you have the option to verify the election.")
      end

      it "shows that file and checksum are not available" do
        expect(page).not_to have_content("Not yet available")

        within ".card__support" do
          expect(page).to have_content("Download")
        end
      end
    end
  end
end
