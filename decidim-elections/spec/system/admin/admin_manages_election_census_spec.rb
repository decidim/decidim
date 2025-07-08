# frozen_string_literal: true

require "spec_helper"

describe "Admin manages election census" do
  let(:manifest_name) { "elections" }
  let(:participatory_process) { create(:participatory_process, organization:) }
  let(:current_component) { create(:component, participatory_space: participatory_process, manifest_name: "elections") }
  let!(:election) { create(:election, component: current_component) }
  let!(:questions) { create_list(:election_question, 3) }

  include_context "when managing a component as an admin"

  before do
    visit election_census_path
  end

  it "opens the census tab" do
    expect(page).to have_content("Type of census")
  end

  context "when the admin selects unregistered participants with tokens" do
    context "when the csv file is valid" do
      it "uploads the CSV file and creates participants" do
        select "Unregistered participants with tokens (fixed)", from: "census_manifest"
        expect(page).to have_content("Upload a CSV file")
        dynamically_attach_file("token_csv_file", Decidim::Dev.asset("valid_election_census.csv")) # with 2 users

        click_on "Save and continue" # redirects to the dashboard
        expect(page).to have_content("Census updated successfully")
        expect(page).to have_css("h1", text: "Dashboard")

        visit election_census_path

        expect(page).to have_content("There are currently 2 people")
        expect(page).to have_content("User preview (the list is limited to 5 records")
        expect(page).to have_content("user1@example.org")
        expect(page).to have_content("user2@example.org")
      end
    end

    context "when the csv file is invalid" do
      it "shows an error message" do
        select "Unregistered participants with tokens (fixed)", from: "census_manifest"
        expect(page).to have_content("Upload a CSV file")
        dynamically_attach_file("token_csv_file", Decidim::Dev.asset("census_with_missing_email.csv")) # has a row with missing email and 1 valid row

        click_on "Save and continue" # redirects to the dashboard
        expect(page).to have_css("h1", text: "Dashboard")

        visit election_census_path

        expect(page).to have_content("There is currently 1 person")
        expect(page).to have_content("User preview (the list is limited to 5 records")
      end
    end

    context "when the csv file has duplicate emails" do
      it "shows an error about duplicate records" do
        select "Unregistered participants with tokens (fixed)", from: "census_manifest"
        expect(page).to have_content("Upload a CSV file")
        dynamically_attach_file("token_csv_file", Decidim::Dev.asset("census_duplicate_emails.csv")) # has 3 the same rows

        click_on "Save and continue" # redirects to the dashboard
        expect(page).to have_css("h1", text: "Dashboard")

        visit election_census_path

        expect(page).to have_content("There is currently 1 person")
        expect(page).to have_content("User preview (the list is limited to 5 records")
        expect(page).to have_content("user1@example.org")
      end
    end
  end

  context "when the admin selects registered participants (dynamic)" do
    let!(:users) { create_list(:user, 10, :confirmed, organization:) }
    let(:authorized_users) { create_list(:user, 3, :confirmed, organization:) }
    let(:another_authorized_users) { create_list(:user, 2, :confirmed, organization:) }
    let(:authorization_handler_name) { "dummy_authorization_handler" }
    let(:another_authorization_handler_name) { "another_dummy_authorization_handler" }
    let(:available_authorizations) { [authorization_handler_name, another_authorization_handler_name] }

    before do
      organization.update!(available_authorizations: available_authorizations)
    end

    context "when no verification handlers are selected" do
      it "shows all organization users in the preview" do
        select "Registered participants (dynamic)", from: "census_manifest"
        expect(page).to have_content("Additional required authorizations to vote (optional)")

        click_on "Save and continue" # redirects to the dashboard
        expect(page).to have_css("h1", text: "Dashboard")

        visit election_census_path

        expect(page).to have_content("There are currently 11 people eligible for voting in this election (this might change on a dynamic census).") # 1 admin + 10 users
        expect(page).to have_content("User preview (the list is limited to 5 records)")
        expect(page).to have_css("table.table-list tbody tr", count: 5)
      end
    end

    context "when verification handlers are selected" do
      before do
        authorized_users.each do |user|
          create(:authorization, user:, name: "dummy_authorization_handler", granted_at: Time.current)
        end

        another_authorized_users.each do |user|
          create(:authorization, user:, name: "another_dummy_authorization_handler", granted_at: Time.current)
        end
      end

      it "shows only users with selected authorizations" do
        select "Registered participants (dynamic)", from: "census_manifest"
        expect(page).to have_content("Additional required authorizations to vote (optional)")

        check "Example authorization"
        click_on "Save and continue" # redirects to the dashboard
        expect(page).to have_css("h1", text: "Dashboard")

        visit election_census_path

        expect(page).to have_content("There are currently 3 people eligible for voting in this election (this might change on a dynamic census).")
        expect(page).to have_content("User preview (the list is limited to 5 records)")
        expect(page).to have_css("table.table-list tbody tr", count: 3)
      end

      context "when multiple verification handlers are selected" do
        let!(:user_with_multiple_authorizations) { create(:user, :confirmed, organization:) }

        before do
          create(:authorization, user: user_with_multiple_authorizations, name: authorization_handler_name, granted_at: Time.current)
          create(:authorization, user: user_with_multiple_authorizations, name: another_authorization_handler_name, granted_at: Time.current)
        end

        it "shows only users with all selected authorizations" do
          select "Registered participants (dynamic)", from: "census_manifest"
          expect(page).to have_content("Additional required authorizations to vote (optional)")

          check "Example authorization"
          check "Another example authorization"

          click_on "Save and continue" # redirects to the dashboard
          expect(page).to have_css("h1", text: "Dashboard")

          visit election_census_path

          expect(page).to have_content("There is currently 1 person eligible for voting in this election (this might change on a dynamic census).")
          expect(page).to have_content("User preview (the list is limited to 5 records)")
          expect(page).to have_css("table.table-list tbody tr", count: 1)
        end
      end
    end
  end

  private

  def election_census_path
    Decidim::EngineRouter.admin_proxy(component).election_census_path(election)
  end
end
