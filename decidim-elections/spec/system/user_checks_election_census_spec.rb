# frozen_string_literal: true

require "spec_helper"

describe "Election census check" do
  let(:component) { create(:elections_component) }
  let(:organization) { component.organization }

  before do
    switch_to_host(organization.host)
  end

  context "when the election is scheduled" do
    let(:election_path) { Decidim::EngineRouter.main_proxy(component).election_path(election) }
    let(:new_census_check_path) { Decidim::EngineRouter.main_proxy(component).new_election_census_check_path(election) }
    let(:census_check_path) { Decidim::EngineRouter.main_proxy(component).election_census_check_path(election) }
    let(:voter_data) { election.voters.first.data }

    context "when allow_census_check_before_start is enabled" do
      let!(:election) { create(:election, :published, :scheduled, :with_token_csv_census, component:, allow_census_check_before_start: true) }

      context "when user is a guest" do
        it "displays the census check button" do
          visit election_path

          expect(page).to have_link("Check if I can vote")
        end

        it "allows the user to validate they are in the census" do
          visit election_path

          click_link "Check if I can vote"

          expect(page).to have_current_path(new_census_check_path)

          fill_in "Email", with: voter_data["email"]
          fill_in "Token", with: voter_data["token"]
          click_button "Access"

          expect(page).to have_current_path(census_check_path)
          expect(page).to have_content("You have been successfully verified")
          expect(page).to have_content("This means that, once the election starts, you can vote in it.")

          click_link "Exit the census check"

          expect(page).to have_current_path(election_path)
        end
      end

      context "when user is logged in" do
        let(:user) { create(:user, :confirmed, organization:) }

        before do
          login_as user, scope: :user
        end

        it "displays the census check button" do
          visit election_path

          expect(page).to have_link("Check if I can vote")
        end
      end

      context "when user is an admin" do
        let(:admin) { create(:user, :admin, :confirmed, organization:) }

        before do
          login_as admin, scope: :user
        end

        it "displays the census check button" do
          visit election_path

          expect(page).to have_link("Check if I can vote")
        end
      end
    end

    context "when allow_census_check_before_start is disabled" do
      let!(:election) { create(:election, :published, :scheduled, :with_token_csv_census, component:, allow_census_check_before_start: false) }

      context "when user is a guest" do
        it "does not display the census check button" do
          visit election_path

          expect(page).to have_no_link("Check if I can vote")
        end
      end

      context "when user is logged in" do
        let(:user) { create(:user, :confirmed, organization:) }

        before do
          login_as user, scope: :user
        end

        it "does not display the census check button" do
          visit election_path

          expect(page).to have_no_link("Check if I can vote")
        end
      end

      context "when user is an admin" do
        let(:admin) { create(:user, :admin, :confirmed, organization:) }

        before do
          login_as admin, scope: :user
        end

        it "does not display the census check button" do
          visit election_path

          expect(page).to have_no_link("Check if I can vote")
        end
      end
    end
  end

  context "when the election is not published" do
    let!(:election) { create(:election, :scheduled, :with_token_csv_census, component:) }
    let(:election_path) { Decidim::EngineRouter.main_proxy(component).election_path(election) }
    let(:new_census_check_path) { Decidim::EngineRouter.main_proxy(component).new_election_census_check_path(election) }
    let(:census_check_path) { Decidim::EngineRouter.main_proxy(component).election_census_check_path(election) }
    let(:voter_data) { election.voters.first.data }
    let(:admin) { create(:user, :admin, :confirmed, organization:) }

    before do
      login_as admin, scope: :user
    end

    it "displays the census check button for admin preview" do
      visit election_path

      expect(page).to have_link("Check if I can vote")
    end

    it "allows the admin to preview the census check" do
      visit election_path

      click_link "Check if I can vote"

      expect(page).to have_current_path(new_census_check_path)

      fill_in "Email", with: voter_data["email"]
      fill_in "Token", with: voter_data["token"]
      click_button "Access"

      expect(page).to have_current_path(census_check_path)
      expect(page).to have_content("You have been successfully verified")
    end
  end

  context "when the election uses the internal users census" do
    let(:authorization_handlers) { { "dummy_authorization_handler" => { "options" => { "allowed_postal_codes" => "08002" } } } }
    let(:election) { create(:election, :published, :scheduled, component:, census_manifest: "internal_users", census_settings: { "authorization_handlers" => authorization_handlers }, allow_census_check_before_start: true) }
    let(:election_path) { Decidim::EngineRouter.main_proxy(component).election_path(election) }
    let(:new_census_check_path) { Decidim::EngineRouter.main_proxy(component).new_election_census_check_path(election) }
    let(:census_check_path) { Decidim::EngineRouter.main_proxy(component).election_census_check_path(election) }

    context "with an authorized participant" do
      let(:user) { create(:user, :confirmed, organization:) }

      before do
        create(:authorization, user:, name: "dummy_authorization_handler", metadata: { "postal_code" => "08002" })
        login_as user, scope: :user
      end

      it "confirms they will be able to vote" do
        visit election_path

        click_link "Check if I can vote"

        expect(page).to have_current_path(census_check_path)
        expect(page).to have_content("You have been successfully verified")
        expect(page).to have_content("This means that, once the election starts, you can vote in it.")

        click_link "Exit the census check"

        expect(page).to have_current_path(election_path)
      end
    end

    context "with a participant without the required authorizations" do
      let(:user) { create(:user, :confirmed, organization:) }

      before do
        login_as user, scope: :user
      end

      it "blocks the access" do
        visit election_path

        click_link "Check if I can vote"

        expect(page).to have_current_path(new_census_check_path)
        expect(page).to have_content("Verify your identity")

        click_button "Access"

        expect(page).to have_current_path(new_census_check_path)
        expect(page).to have_content("You are not authorized to vote in this election.")
      end
    end
  end

  context "when the election is ongoing" do
    let!(:election) { create(:election, :published, :ongoing, :with_token_csv_census, component:) }
    let(:election_path) { Decidim::EngineRouter.main_proxy(component).election_path(election) }

    it "does not display the census check button" do
      visit election_path

      expect(page).to have_no_link("Check if I can vote")
    end
  end
end
