# frozen_string_literal: true

require "spec_helper"

describe "Assembly admin accesses admin sections", type: :system do
  include_context "when assembly admin administrating an assembly"

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  context "when is a mother assembly" do
    it "can access all sections" do
      visit decidim_admin_assemblies.assemblies_path
      click_link translated(assembly.title)

      within ".secondary-nav" do
        expect(page).to have_content("Info")
        expect(page).to have_content("Components")
        expect(page).to have_content("Categories")
        expect(page).to have_content("Attachments")
        expect(page).to have_content("Folders")
        expect(page).to have_content("Files")
        expect(page).to have_content("Members")
        expect(page).to have_content("Assembly admins")
        expect(page).to have_content("Private users")
        expect(page).to have_content("Moderations")
      end
    end
  end

  context "when is a child assembly" do
    let!(:child_assembly) { create :assembly, parent: assembly, organization:, hashtag: "child" }

    before do
      visit decidim_admin_assemblies.assemblies_path
      within find("tr", text: translated(assembly.title)) do
        click_link "Assemblies"
      end

      click_link translated(child_assembly.title)
    end

    it "can access all sections" do
      within ".secondary-nav" do
        expect(page).to have_content("Info")
        expect(page).to have_content("Components")
        expect(page).to have_content("Categories")
        expect(page).to have_content("Attachments")
        expect(page).to have_content("Folders")
        expect(page).to have_content("Files")
        expect(page).to have_content("Members")
        expect(page).to have_content("Assembly admins")
        expect(page).to have_content("Private users")
        expect(page).to have_content("Moderations")
      end
    end

    it_behaves_like "assembly admin manage assembly components"
  end
end
