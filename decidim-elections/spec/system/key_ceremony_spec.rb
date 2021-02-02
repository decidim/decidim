# frozen_string_literal: true

require "spec_helper"

describe "Key ceremony", type: :system do
  let!(:election) { create :election, :ready_for_setup, id: 42, trustee_keys: trustee_keys, component: current_component }

  let(:manifest_name) { "elections" }
  let(:trustee_keys) do
    {
      "Trustee 1" => File.read(Decidim::Dev.asset("public_key.jwk")),
      "Trustee 2" => File.read(Decidim::Dev.asset("public_key2.jwk"))
    }
  end
  let(:private_keys) do
    [
      Decidim::Dev.asset("private_key.jwk"),
      Decidim::Dev.asset("private_key2.jwk")
    ]
  end

  describe "key ceremony process" do
    include_context "when mocking the bulletin board in the browser"

    include_context "when managing a component as an admin" do
      let(:admin_component_organization_traits) { [:secure_context] }
    end

    context "when performing the key ceremony", :vcr, :billy, :slow, download: true do
      it "generates backup keys, restores them and creates election keys" do
        setup_election(election)

        proxy.cache.with_scope("trustee 1 download") { download_election_keys(0) }
        proxy.cache.with_scope("trustee 2 download") { download_election_keys(1) }

        proxy.cache.with_scope("complete ceremony with trustee 1") { complete_key_ceremony(0) }
        proxy.cache.with_scope("check complete ceremony with trustee 2") { check_key_ceremony_completed(1) }
      end
    end

    def setup_election(election)
      login_as user, scope: :user
      visit_component_admin

      within find("tr", text: translated(election.title)) do
        page.find(".action-icon--manage-steps").click
      end

      click_button "Setup election"

      click_button "Start the key ceremony"

      within ".content.key_ceremony" do
        expect(page).to have_content("Key ceremony")
      end

      election.reload
    end

    def download_election_keys(trustee_index)
      trustee = access_trustee_zone(trustee_index)

      perform_key_ceremony_action

      click_link "Download keys"

      content = download_content("#{trustee.unique_id}-*.bak")
      expect(content).to have_content(%(trusteeId":"#{trustee.unique_id}))
      expect(content).to have_content('"status":1')
    end

    def access_trustee_zone(trustee_index, upload_keys = true) # rubocop:disable Style/OptionalBooleanParameter
      trustee = election.trustees[trustee_index]

      relogin_as trustee.user, scope: :user
      visit decidim.decidim_elections_trustee_zone_path

      if upload_keys
        attach_file(private_keys[trustee_index]) do
          click_button "Upload your identification keys"
        end
      end

      expect(page).not_to have_content("Upload your identification keys")

      trustee
    end

    def perform_key_ceremony_action
      expect(page).to have_content("Elections")

      click_link "Perform action"

      expect(page).to have_content("Create election keys")
      expect(page).to have_css("#create_election", text: "Pending")
      expect(page).to have_css("#key_ceremony-step_1", text: "Pending")
      expect(page).to have_css("#key_ceremony-joint_election_key", text: "Pending")

      expect(page).to have_selector("button.start:not(disabled)")

      sleep(1)

      click_button "Start"

      expect(page).to have_selector("button.start:disabled")
    end

    def complete_key_ceremony(trustee_index)
      trustee = access_trustee_zone(trustee_index, false)

      perform_key_ceremony_action

      expect(page).to have_content("Restore election keys for #{translated(election.title, locale: :en)}")

      attach_file(download_path("#{trustee.unique_id}-*.bak")) do
        page.find_all(:xpath, "//*[normalize-space(text())='Upload election keys']").first.click
      end

      expect(page).to have_css("#create_election", text: "Completed")
      expect(page).to have_css("#key_ceremony-step_1", text: "Completed")
      expect(page).to have_css("#key_ceremony-joint_election_key", text: "Completed")
      expect(page).not_to have_selector("button.start")
      expect(page).to have_link("Back")

      expect(page).to have_content("The election status is: key_ceremony_ended")
    end

    def check_key_ceremony_completed(trustee_index)
      access_trustee_zone(trustee_index, false)

      expect(page).to have_content("Elections")

      within ".trustee_zone table" do
        expect(page).to have_content(translated(election.title, locale: :en))
        expect(page).to have_content("key_ceremony_ended")
        expect(page).not_to have_link("Perform action")
      end
    end
  end
end
