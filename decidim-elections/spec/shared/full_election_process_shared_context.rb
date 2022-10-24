# frozen_string_literal: true

shared_context "when performing the whole process" do
  include_context "with test bulletin board"
  include_context "when admin manages elections"

  let(:trustee_keys) do
    {
      "Trustee 1" => File.read(Decidim::Dev.asset("public_key.jwk")),
      "Trustee 2" => File.read(Decidim::Dev.asset("public_key2.jwk")),
      "Trustee 3" => File.read(Decidim::Dev.asset("public_key3.jwk"))
    }
  end
  let(:private_keys) do
    [
      Decidim::Dev.asset("private_key.jwk"),
      Decidim::Dev.asset("private_key2.jwk"),
      Decidim::Dev.asset("private_key3.jwk")
    ]
  end
  let(:election) { create :election, :ready_for_setup, trustee_keys:, component: current_component }
end

module Decidim
  module Elections
    module FullElectionHelpers
      def setup_election
        election

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

        content = download_content("#{trustee.slug}-*.bak")
        expect(content).to have_content(%(trusteeId":"#{trustee.slug}))
        expect(content).to have_content('"status":2')
      end

      def access_trustee_zone(trustee_index, upload_keys = true) # rubocop:disable Style/OptionalBooleanParameter
        trustee = election.trustees[trustee_index]

        relogin_as trustee.user, scope: :user
        visit decidim.decidim_elections_trustee_zone_path

        if upload_keys
          expect(page).to have_content("Upload your identification keys")
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

        attach_file(download_path("#{trustee.slug}-*.bak")) do
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
end
