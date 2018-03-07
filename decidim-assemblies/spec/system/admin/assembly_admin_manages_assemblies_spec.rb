# frozen_string_literal: true

require "spec_helper"

describe "Assembly admin manages assemblies", type: :system do
  include_context "when assembly admin administrating an assembly"

  shared_context "creating an assembly" do
    it "cannot create a new assembly" do
      expect(page).to have_no_selector(".actions .new")
    end
  end

  shared_context "deleting an assembly" do
    it "cannot delete an assembly" do
      within find("tr", text: translated(assembly.title)) do
        expect(page).to have_no_content("Destroy")
      end
    end
  end

  context "managing parent assemblies" do
    let(:parent_assembly) { nil }

    before do
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit decidim_admin_assemblies.assemblies_path
    end

    it_behaves_like "manage assemblies"
    it_behaves_like "creating an assembly"
    it_behaves_like "deleting an assembly"
  end

  context "managing child assemblies" do
    let!(:parent_assembly) { create :assembly, organization: organization }
    let!(:child_assembly) { create :assembly, organization: organization, parent: parent_assembly }
    let(:assembly) { child_assembly }

    before do
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit decidim_admin_assemblies.assemblies_path
      within find("tr", text: translated(parent_assembly.title)) do
        click_link "Assemblies"
      end
    end

    it_behaves_like "manage assemblies"
    it_behaves_like "creating an assembly"
    it_behaves_like "deleting an assembly"
  end
end
