# frozen_string_literal: true

require "spec_helper"

describe "import private users via csv with the possibility to deleting some", type: :system do
  let(:organization) { create(:organization) }

  let!(:user) { create(:user, :admin, :confirmed, organization: organization) }
  let(:assembly) { create(:assembly, organization: organization) }

  before do
    (0..5).each do |_i|
      user = create :user, organization: organization
      create :assembly_private_user, user: user, privatable_to: assembly
    end
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_assemblies.edit_assembly_path(assembly)
    find("a[href*='participatory_space_private_users']").click
    find("a[href*='csv_import'").click
  end

  it "show the form to add some private users via csv" do
    expect(page).to have_content("Upload your CSV file")
  end

  context "when the user doesn't want to delete existing users" do
    it "doesn't show the warning" do
      expect(page).not_to have_selector(".delete-current-warning")
    end

    it "doesn't ask for confirmation" do
      find("button[type='submit']").click

      expect { page.driver.browser.switch_to.alert }.to raise_error(Selenium::WebDriver::Error::NoSuchAlertError)
    end
  end

  context "when the user want to delete existing users" do
    before do
      find("input[type='checkbox']").click
    end

    it "show the warning" do
      expect(page).to have_selector(".delete-current-warning")
    end

    it "ask you for confirmation" do
      find("button[type='submit']").click

      expect(page.driver.browser.switch_to.alert.text).to eq("Are you sure you want to delete all current participants ?")
    end
  end
end
