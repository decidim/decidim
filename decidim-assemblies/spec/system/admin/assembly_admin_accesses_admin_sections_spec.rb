# frozen_string_literal: true

require "spec_helper"

describe "Assembly admin accesses admin sections" do
  include_context "when assembly admin administrating an assembly"

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  shared_examples "sees public space menu" do
    it "can access all sections" do
      expect(page).to have_content("Info")
      expect(page).to have_content("Components")
      expect(page).to have_content("Attachments")
      expect(page).to have_content("Assembly admins")
      expect(page).to have_no_content("Members")
      expect(page).to have_content("Moderations")
    end
  end

  shared_examples "sees private space menu" do
    it "can access all sections" do
      expect(page).to have_content("Info")
      expect(page).to have_content("Components")
      expect(page).to have_content("Attachments")
      expect(page).to have_content("Assembly admins")
      expect(page).to have_content("Members")
      expect(page).to have_content("Moderations")
    end
  end

  context "when is a mother assembly" do
    before do
      visit decidim_admin_assemblies.assemblies_path
      within "tr", text: translated(assembly.title) do
        find("button[data-component='dropdown']").click
        click_on "Configure"
      end
    end

    context "when is a public assembly" do
      it_behaves_like "sees public space menu"
    end

    context "when is a private assembly" do
      let(:assembly) { create(:assembly, organization:, private_space: true) }

      it_behaves_like "sees private space menu"
    end
  end

  context "when is a child assembly" do
    let!(:child_assembly) { create(:assembly, parent: assembly, organization:, hashtag: "child") }

    before do
      visit decidim_admin_assemblies.edit_assembly_path(child_assembly)
    end

    context "when is a public assembly" do
      it_behaves_like "sees public space menu"
    end

    context "when is a private assembly" do
      let(:child_assembly) { create(:assembly, parent: assembly, organization:, private_space: true) }

      it_behaves_like "sees private space menu"
    end

    it_behaves_like "assembly admin manage assembly components"
  end
end
