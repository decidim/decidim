# frozen_string_literal: true

require "spec_helper"

describe "Admin manages polling officers", type: :system do
  include_context "when admin managing a voting"

  let(:csv_file) { upload_test_file(Decidim::Dev.test_file("import_voting_census.csv", "text/csv")) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_votings.edit_voting_path(voting)
    click_link "Census"
  end

  context "when init_data" do
    it "shows a form to upload a csv file" do
      expect(page).to have_content("There is no census yet")
      expect(page).to have_content("Create the census")
    end

    it "uploads a csv" do
      dynamically_attach_file(:dataset_file, Decidim::Dev.asset("import_voting_census.csv"))
      within ".form.new_census" do
        find("*[type=submit]").click
      end

      expect(page).to have_content("Please wait")
    end
  end

  context "when data is invalid" do
    before do
      create :dataset, :data_created, voting: voting
      visit decidim_admin_votings.voting_census_path(voting)
    end

    it "shows the processed file result" do
      expect(page).to have_admin_callout("Finished processing")
      expect(page).not_to have_content("You can now proceed to generate the access codes")
      expect(page).to have_content("Please delete the current census and start over")
    end

    it "shows an option to delete the census" do
      expect(page).to have_link("Delete all census data", count: 2)
    end

    context "when deleting the census" do
      it "deletes the census" do
        within "#wrapper-action-view" do
          accept_confirm { click_link "Delete all census data" }
        end

        expect(page).to have_admin_callout("Census data deleted")
        expect(page).to have_content("There is no census yet")
      end
    end
  end

  context "when data exists" do
    before do
      create :dataset, :data_created, :with_data, voting: voting
      visit decidim_admin_votings.voting_census_path(voting)
    end

    it "shows the processed file result" do
      expect(page).to have_admin_callout("Finished processing")
      expect(page).to have_content("You can now proceed to generate the access codes")
    end

    it "shows an option to delete the census" do
      expect(page).to have_link("Delete all census data")
    end

    context "when deleting the census" do
      it "deletes the census" do
        within ".voting-content" do
          accept_confirm { click_link "Delete all census data" }
        end

        expect(page).to have_admin_callout("Census data deleted")
        expect(page).to have_content("There is no census yet")
      end
    end

    it "shows an option to generate the access codes" do
      expect(page).to have_link("Generate voting Access Codes")
    end

    context "when generating the access codes" do
      it "deletes the census" do
        within ".voting-content" do
          accept_confirm { click_link "Generate voting Access Codes" }
        end

        expect(page).to have_content("Please wait")
      end
    end
  end

  context "when access codes have been generated" do
    before do
      create :dataset, :codes_generated, voting: voting
      visit decidim_admin_votings.voting_census_path(voting)
    end

    it "exports the access codes" do
      within ".voting-content" do
        accept_confirm { click_link "Export voting Access Codes" }
      end

      expect(page).to have_admin_callout("Access codes export launched")
      expect(page).to have_admin_callout(user.email)
    end
  end

  context "when census is frozen" do
    before do
      create :dataset, :frozen, voting: voting
      visit decidim_admin_votings.voting_census_path(voting)
    end

    it "Shows that the census is frozen" do
      expect(page).to have_content("The census is frozen")
    end
  end
end
