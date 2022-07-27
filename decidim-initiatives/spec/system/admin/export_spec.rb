# frozen_string_literal: true

require "spec_helper"

describe "Admin exports initiatives", type: :system do
  include_context "with filterable context"

  let!(:initiatives) do
    create_list(:initiative, 3, organization:)
  end

  let!(:created_initiative) do
    create(:initiative, :created, organization:)
  end

  let(:user) { create(:user, :admin, :confirmed, organization:) }
  let(:organization) { create(:organization) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  context "when accessing initiatives list" do
    it "shows the export dropdown" do
      visit decidim_admin_initiatives.initiatives_path

      within ".card-title" do
        expect(page).to have_content("Export all")
        expect(page).not_to have_content("Export selection")
      end
    end
  end

  context "when clicking the export dropdown" do
    before do
      visit decidim_admin_initiatives.initiatives_path
    end

    it "shows the export formats" do
      find("span", text: "Export all").click

      expect(page).to have_content("Initiatives as CSV")
      expect(page).to have_content("Initiatives as JSON")
    end
  end

  context "when clicking the export link" do
    before do
      visit decidim_admin_initiatives.initiatives_path
      find("span", text: "Export all").click
    end

    it "displays success message" do
      click_link "Initiatives as JSON"

      expect(page).to have_content("Your export is currently in progress. You'll receive an email when it's complete.")
    end
  end

  context "when initiatives are filtered" do
    context "when accessing initiatives list" do
      it "shows the export dropdown" do
        visit decidim_admin_initiatives.initiatives_path
        apply_filter("State", "Created")

        within ".card-title" do
          expect(page).to have_content("Export all")
          expect(page).to have_content("Export selection")
        end
      end
    end

    context "when clicking the export dropdown" do
      before do
        visit decidim_admin_initiatives.initiatives_path
        apply_filter("State", "Created")
      end

      it "shows the export formats" do
        find("span", text: "Export selection").click

        expect(page).to have_content("Initiatives as CSV")
        expect(page).to have_content("Initiatives as JSON")
      end
    end

    context "when clicking the export link" do
      before do
        visit decidim_admin_initiatives.initiatives_path
        apply_filter("State", "Created")
        find("span", text: "Export selection").click
      end

      it "displays success message" do
        click_link "Initiatives as JSON"

        expect(page).to have_content("Your export is currently in progress. You'll receive an email when it's complete.")
      end
    end
  end
end
