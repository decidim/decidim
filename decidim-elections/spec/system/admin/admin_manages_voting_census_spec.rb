# frozen_string_literal: true

require "spec_helper"

describe "Admin manages polling officers", type: :system do
  include_context "when admin managing a voting"

  let(:csv_file) { Decidim::Dev.test_file("import_voting_census.csv", "text/csv") }

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
      within ".form.new_census" do
        attach_file "File", Decidim::Dev.asset("verify_user_groups.csv")

        find("*[type=submit]").click
      end

      expect(page).to have_content("Please wait")
    end
  end

  context "when data exists" do
    before do
      create :dataset, :data_created, :with_datum, voting: voting
      visit decidim_admin_votings.voting_census_path(voting)
    end

    it "shows the processed file result" do
      expect(page).to have_admin_callout("Finished processing")
      expect(page).to have_content("All rows imported successfully")
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
end
