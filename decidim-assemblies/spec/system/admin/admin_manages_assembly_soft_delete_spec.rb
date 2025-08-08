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
      expect(page).to have_no_link("View deleted assemblies", href: /.*assemblies.*trash.*/)
    end
  end

  context "when a user is evaluator" do
    let!(:assembly) { create(:assembly, organization: organization) }
    let!(:evaluator_user) { create(:user, :admin_terms_accepted, :confirmed, organization: organization) }
    let!(:evaluator_role) do
      create(:assembly_user_role,
             user: evaluator_user,
             assembly: assembly,
             role: :evaluator)
    end

    before do
      switch_to_host(organization.host)
      login_as evaluator_user, scope: :user
      visit admin_resource_path
    end

    it "does not allow evaluators to view deleted assemblies" do
      expect(page).to have_content("Assemblies")
      expect(page).to have_no_link("View deleted assemblies", href: /.*assemblies.*trash.*/)
    end
  end

  context "when a user is moderator" do
    let!(:assembly) { create(:assembly, organization: organization) }
    let!(:moderator_user) { create(:user, :admin_terms_accepted, :confirmed, organization: organization) }
    let!(:moderator_role) do
      create(:assembly_user_role,
             user: moderator_user,
             assembly: assembly,
             role: :moderator)
    end

    before do
      switch_to_host(organization.host)
      login_as moderator_user, scope: :user
      visit admin_resource_path
    end

    it "does not allow moderators to view deleted assemblies" do
      expect(page).to have_content("Assemblies")
      expect(page).to have_no_link("View deleted assemblies", href: /.*assemblies.*trash.*/)
    end
  end

  context "when a user is a space admin" do
    let!(:assembly) { create(:assembly, organization: organization) }
    let!(:admin_user) { create(:user, :admin_terms_accepted, :confirmed, organization: organization) }
    let!(:admin_role) do
      create(:assembly_user_role,
             user: admin_user,
             assembly: assembly,
             role: :admin)
    end

    before do
      switch_to_host(organization.host)
      login_as admin_user, scope: :user
      visit admin_resource_path
    end

    it "does not allow space admins to view deleted assemblies" do
      expect(page).to have_content("Assemblies")
      expect(page).to have_no_link("View deleted assemblies", href: /.*assemblies.*trash.*/)
    end
  end
end
