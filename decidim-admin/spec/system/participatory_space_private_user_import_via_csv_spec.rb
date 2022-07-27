# frozen_string_literal: true

require "spec_helper"

describe "Admin manages participatory space private users via csv import", type: :system do
  let(:organization) { create(:organization) }

  let!(:user) { create(:user, :admin, :confirmed, organization:) }
  let(:assembly) { create(:assembly, organization:) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_assemblies.edit_assembly_path(assembly)
    find("a[href*='participatory_space_private_users']").click
    find("a[href*='csv_import'").click
  end

  it "show the form to add some private users via csv" do
    expect(page).to have_content("Upload your CSV file")
  end

  context "when there are no existing users" do
    it "doesn't propose to delete" do
      expect(page).to have_content("You have no private participants.")
    end
  end

  context "when there are existing users" do
    before do
      create_list :assembly_private_user, 3, privatable_to: assembly, user: create(:user, organization: assembly.organization)
      visit current_path
    end

    it "propose to delete" do
      expect(page).to have_selector(".alert")
    end

    it "ask you for confirmation and delete existing users" do
      find(".alert").click

      expect(page).to have_content("Are you sure you want to delete all private participants?")

      find("a.button[data-confirm-ok]").click

      expect(page).to have_content("You have no private participants")
    end
  end
end
