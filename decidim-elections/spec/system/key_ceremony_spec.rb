# frozen_string_literal: true

require "spec_helper"

describe "Key ceremony", type: :system do
  let!(:election) { create :election, :published, :ready_for_setup, trustee_keys: trustee_keys, component: current_component }

  let(:manifest_name) { "elections" }
  let(:trustee_1) { election.trustees.first }
  let(:trustee_2) { election.trustees.last }
  let(:trustee_keys) do
    [
      File.read(Decidim::Dev.asset("public_key.jwk")),
      File.read(Decidim::Dev.asset("public_key2.jwk"))
    ]
  end

  describe "key ceremony process" do
    include_context "when managing a component as an admin" do
      let(:admin_component_organization_traits) { [:secure_context] }
    end

    context "when performing the key ceremony", :vcr do
      it "generates backup keys, restores them and creates election keys", :slow, download: true do
        setup_election(election)

        generate_backup_keys

        sleep(2)

        restore_backup_keys

        sleep(2)

        perform_key_ceremony_step_1(trustee_2, "private_key2")

        expect(page).to have_css("#create_election", text: "Completed")
        expect(page).to have_css("#key_ceremony-step_1", text: "Completed")
        expect(page).to have_css("#key_ceremony-joint_election_key", text: "Completed")
        expect(page).not_to have_selector("button.start")
        expect(page).to have_link("Back")

        expect(page).to have_content("The election status is: ready")

        relogin_as trustee_1.user, scope: :user
        visit decidim.decidim_elections_trustee_zone_path
        expect(page).to have_content("Elections")

        within ".trustee_zone table" do
          expect(page).to have_content(translated(election.title, locale: :en))
          expect(page).to have_content("ready")
          expect(page).not_to have_link("Perform action")
        end
      end
    end

    def setup_election(election)
      login_as user, scope: :user
      visit_component_admin

      within find("tr", text: translated(election.title)) do
        page.find(".action-icon--setup-election").click
      end

      within ".setup_election" do
        page.find(".button").click
      end

      election.reload
    end

    def trustee_download_path(trustee)
      downloads.select { |x| x.include?(trustee.unique_id) }
    end

    def generate_backup_keys
      login_as trustee_1.user, scope: :user
      visit decidim.decidim_elections_trustee_zone_path

      attach_file(Decidim::Dev.asset("private_key.jwk")) do
        click_button "Upload your identification keys"
      end

      expect(page).not_to have_content("Upload your identification keys")
      expect(page).to have_content("Elections")

      click_link "Perform action"

      expect(page).to have_content("Create election keys")
      expect(page).to have_css("#create_election", text: "Pending")
      expect(page).to have_css("#key_ceremony-step_1", text: "Pending")
      expect(page).to have_css("#key_ceremony-joint_election_key", text: "Pending")

      expect(page).to have_selector("button.start:not(disabled)")

      click_button "Start"

      expect(page).to have_selector("button.start:disabled")

      click_button "Download keys"
    end

    def restore_backup_keys
      relogin_as trustee_1.user, scope: :user
      visit decidim.decidim_elections_trustee_zone_path

      click_link "Perform action"

      expect(page).to have_selector("button.start:not(disabled)")

      click_button "Start"

      expect(page).to have_content("Restore election keys for #{translated(election.title, locale: :en)}")

      attach_file(trustee_download_path(trustee_1).first) do
        click_button "Upload election keys"
      end
    end

    def perform_key_ceremony_step_1(trustee, private_key)
      relogin_as trustee.user, scope: :user
      visit decidim.decidim_elections_trustee_zone_path

      attach_file(Decidim::Dev.asset("#{private_key}.jwk")) do
        click_button "Upload your identification keys"
      end

      expect(page).not_to have_content("Upload your identification keys")
      expect(page).to have_content("Elections")

      click_link "Perform action"

      expect(page).to have_content("Create election keys")
      expect(page).to have_css("#create_election", text: "Pending")
      expect(page).to have_css("#key_ceremony-step_1", text: "Pending")
      expect(page).to have_css("#key_ceremony-joint_election_key", text: "Pending")

      expect(page).to have_selector("button.start:not(disabled)")

      click_button "Start"

      expect(page).to have_selector("button.start:disabled")

      click_button "Download keys"

      sleep(2)

      expect(File.basename(trustee_download_path(trustee).first)).to eq "#{trustee.unique_id}-election-#{election.id}.bak"
      expect(File.read(trustee_download_path(trustee).first)).to have_content(trustee.unique_id)

      expect(download_content).to have_content("status")
      expect(download_content).to have_content("key_ceremony.step_1")
      expect(download_content).to have_content("trusteeId")
    end
  end
end
