# frozen_string_literal: true

require "spec_helper"

describe "Admin manages members via csv import" do
  let(:organization) { create(:organization) }

  let!(:user) { create(:user, :admin, :confirmed, organization:) }
  let(:assembly) { create(:assembly, organization:, has_members: true) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_assemblies.edit_assembly_path(assembly)
    within_admin_sidebar_menu do
      click_on "Members"
    end
    click_on "Import via CSV"
  end

  it "show the form to add some members via csv" do
    expect(page).to have_text("Upload your CSV file")
  end

  context "when there are no existing users" do
    it "does not propose to delete" do
      expect(page).to have_text("You have no members.")
    end
  end

  context "when there are existing users" do
    before do
      create_list(:assembly_member, 3, participatory_space: assembly, organization: assembly.organization)
      visit current_path
    end

    it "propose to delete" do
      expect(page).to have_css(".alert")
    end

    it "ask you for confirmation and delete existing users" do
      find(".alert").click

      expect(page).to have_text("Are you sure you want to delete all members?")

      click_on("OK")

      expect(page).to have_text("You have no members")
    end
  end
end
