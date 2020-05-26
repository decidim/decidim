# frozen_string_literal: true

require "spec_helper"

describe "Admin exports initiatives", type: :system do
  let!(:initiatives) do
    create_list(:initiative, 3, organization: organization)
  end

  let(:user) { create(:user, :admin, :confirmed, organization: organization) }
  let(:organization) { create(:organization) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  context "when accessing initiatives list" do
    it "shows the export dropdown" do
      visit decidim_admin_initiatives.initiatives_path

      expect(page).to have_content("EXPORT")
    end
  end

  context "when clicking the export dropdown" do
    before do
      visit decidim_admin_initiatives.initiatives_path
    end

    it "shows the export formats" do
      page.find(".exports").click

      expect(page).to have_content("INITIATIVES AS CSV")
      expect(page).to have_content("INITIATIVES AS JSON")
    end
  end

  context "when clicking the export link" do
    before do
      visit decidim_admin_initiatives.initiatives_path
      page.find(".exports").click
    end

    it "displays success message" do
      click_link "Initiatives as JSON"

      expect(page).to have_content("Your export is currently in progress. You'll receive an email when it's complete.")
    end
  end
end
