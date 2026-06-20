# frozen_string_literal: true

require "spec_helper"

describe "Assembly admin accesses admin sections" do
  include_context "when assembly admin administrating an assembly"

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  shared_examples "sees menu without members" do
    it "can access all sections" do
      expect(page).to have_text("Info")
      expect(page).to have_text("Components")
      expect(page).to have_text("Attachments")
      expect(page).to have_text("Assembly admins")
      expect(page).to have_no_text("Members")
      expect(page).to have_text("Moderations")
    end
  end

  shared_examples "sees menu with members" do
    it "can access all sections" do
      expect(page).to have_text("Info")
      expect(page).to have_text("Components")
      expect(page).to have_text("Attachments")
      expect(page).to have_text("Assembly admins")
      expect(page).to have_text("Members")
      expect(page).to have_text("Moderations")
    end
  end

  context "when is a mother assembly" do
    before do
      visit decidim_admin_assemblies.assemblies_path
      within "tr", text: translated(assembly.title) do
        find("button[data-controller='dropdown']").click
        click_on "Edit"
      end
    end

    context "when is an assembly without members" do
      it_behaves_like "sees menu without members"
    end

    context "when is an assembly with members" do
      let(:assembly) { create(:assembly, organization:, has_members: true) }

      it_behaves_like "sees menu with members"
    end
  end

  context "when is a child assembly" do
    let!(:child_assembly) { create(:assembly, parent: assembly, organization:) }

    before do
      visit decidim_admin_assemblies.edit_assembly_path(child_assembly)
    end

    context "when is an assembly without" do
      it_behaves_like "sees menu without members"
    end

    context "when is an assembly with members" do
      let(:child_assembly) { create(:assembly, parent: assembly, organization:, has_members: true) }

      it_behaves_like "sees menu with members"
    end

    it_behaves_like "assembly admin manage assembly components"
  end
end
