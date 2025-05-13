# frozen_string_literal: true

require "spec_helper"

describe "Admin manages assembly soft delete" do
  let!(:user) { create(:user, :admin, :confirmed, organization:) }
  let(:organization) { create(:organization) }
  let(:admin_resource_path) { decidim_admin_assemblies.assemblies_path }
  let(:trash_path) { decidim_admin_assemblies.manage_trash_assemblies_path }
  let(:title) { { en: "My space" } }
  let!(:resource) { create(:assembly, title:, organization:) }

  it_behaves_like "manage soft deletable component or space", "assembly"
  it_behaves_like "manage trashed resource", "assembly"

  context "when a user is collaborator" do
    let!(:assembly) { create(:assembly, organization: organization) }
    let!(:collaborator_user) { create(:user, :admin_terms_accepted, :confirmed, organization: organization) }
    let!(:collaborator_role) do
      create(:assembly_user_role,
             user: collaborator_user,
             assembly: assembly,
             role: :collaborator)
    end

    before do
      switch_to_host(organization.host)
      login_as collaborator_user, scope: :user
      visit admin_resource_path
    end

    it "does not allow collaborators to view deleted assemblies" do
      expect(page).to have_content("Assemblies")
      expect(page).to have_no_content("View deleted assemblies")
    end
  end
end
