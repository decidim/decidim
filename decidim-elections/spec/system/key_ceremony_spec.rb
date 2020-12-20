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
      it "admin sets up the election", :slow, download: true do
        in_browser(:admin) do
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

        in_browser(:trustee_one) do
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

          # click_button "Download keys"

          # wait_for_download

          # expect(download_content).to have_content("status")
          # expect(File.basename(download_path)).to eq "#{trustee1.unique_id}-election-#{election.id}.bak"
          # expect(File).to exist(download_path)

          # expect(download_content).to have_content("create_election")
          # expect(download_content).to have_content("trusteeId")
          # expect(download_content).to have_content(trustee_1.unique_id)
        end

        # in_browser(:trustee_two) do
        #   login_as trustee_2.user, scope: :user
        #   visit decidim.decidim_elections_trustee_zone_path

        #   attach_file(Decidim::Dev.asset("private_key2.jwk")) do
        #     click_button "Upload your identification keys"
        #   end

        #   expect(page).not_to have_content("Upload your identification keys")
        #   expect(page).to have_content("Elections")

        #   click_link "Perform action"

        #   expect(page).to have_content("Create election keys")
        #   expect(page).to have_css("#create_election", text: "Pending")
        #   expect(page).to have_css("#key_ceremony-step_1", text: "Pending")
        #   expect(page).to have_css("#key_ceremony-joint_election_key", text: "Pending")

        #   expect(page).to have_selector("button.start:not(disabled)")

        #   click_button "Start"

        #   expect(page).to have_selector("button.start:disabled")

        #   click_button "Download keys"

        #   wait_for_download

        #   # expect(download_content).to have_content("status")
        #   expect(download_content).to have_content("create_election")
        #   # expect(download_content).to have_content("trusteeId")
        #   # expect(download_content).to have_content(trustee_2.unique_id)
        # end
      end
    end
  end
end
