# frozen_string_literal: true

require "spec_helper"

describe "Admin manages assembly soft delete" do
  let!(:user) { create(:user, :admin, :confirmed, organization:) }
  let(:organization) { create(:organization) }
  let(:admin_resource_path) { decidim_admin_assemblies.assemblies_path }
  let(:trash_path) { decidim_admin_assemblies.manage_trash_assemblies_path }
  let(:title) { { en: "My space" } }
  let!(:resource) { create(:assembly, title:, organization:) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit admin_resource_path
  end

  it_behaves_like "manage soft deletable component or space", "assembly"
  it_behaves_like "manage trashed resource", "assembly"

  context "when a user is collaborator" do
    let!(:assembly) { create(:assembly, organization:) }
    let!(:user) { create(:user, :admin_terms_accepted, :confirmed, organization:) }
    let!(:collaborator_role) do
      create(:assembly_user_role,
             user:,
             assembly:,
             role: :collaborator)
    end

    it "does not allow collaborators to view deleted assemblies" do
      expect(page).to have_text("Assemblies")
      expect(page).to have_no_link("View deleted assemblies", href: /.*assemblies.*trash.*/)
    end
  end

  context "when a user is evaluator" do
    let!(:assembly) { create(:assembly, organization:) }
    let!(:user) { create(:user, :admin_terms_accepted, :confirmed, organization:) }
    let!(:evaluator_role) do
      create(:assembly_user_role,
             user:,
             assembly:,
             role: :evaluator)
    end

    it "does not allow evaluators to view deleted assemblies" do
      expect(page).to have_text("Assemblies")
      expect(page).to have_no_link("View deleted assemblies", href: /.*assemblies.*trash.*/)
    end
  end

  context "when a user is moderator" do
    let!(:assembly) { create(:assembly, organization:) }
    let!(:user) { create(:user, :admin_terms_accepted, :confirmed, organization:) }
    let!(:moderator_role) do
      create(:assembly_user_role,
             user:,
             assembly:,
             role: :moderator)
    end

    it "does not allow moderators to view deleted assemblies" do
      expect(page).to have_text("Assemblies")
      expect(page).to have_no_link("View deleted assemblies", href: /.*assemblies.*trash.*/)
    end
  end

  context "when a user is a space admin" do
    let!(:assembly) { create(:assembly, organization:) }
    let!(:user) { create(:user, :admin_terms_accepted, :confirmed, organization:) }
    let!(:admin_role) do
      create(:assembly_user_role,
             user:,
             assembly:,
             role: :admin)
    end

    it "does not allow space admins to view deleted assemblies" do
      expect(page).to have_text("Assemblies")
      expect(page).to have_no_link("View deleted assemblies", href: /.*assemblies.*trash.*/)
    end
  end
end
