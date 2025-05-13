# frozen_string_literal: true

require "spec_helper"

describe "Admin manages conference soft delete" do
  let!(:user) { create(:user, :admin, :confirmed, organization:) }
  let(:organization) { create(:organization) }
  let(:admin_resource_path) { decidim_admin_conferences.conferences_path }
  let(:trash_path) { decidim_admin_conferences.manage_trash_conferences_path }
  let(:title) { { en: "My space" } }
  let!(:resource) { create(:conference, title:, organization:) }

  it_behaves_like "manage soft deletable component or space", "conference"
  it_behaves_like "manage trashed resource", "conference"

  context "when a user is collaborator" do
    let!(:conference) { create(:conference, organization: organization) }
    let!(:collaborator_user) { create(:user, :admin_terms_accepted, :confirmed, organization: organization) }
    let!(:collaborator_role) do
      create(:conference_user_role,
             user: collaborator_user,
             conference: conference,
             role: :collaborator)
    end

    before do
      switch_to_host(organization.host)
      login_as collaborator_user, scope: :user
      visit admin_resource_path
    end

    it "does not allow collaborators to view deleted conferences" do
      expect(page).to have_content("Conferences")
      expect(page).to have_no_content("View deleted conferences")
    end
  end
end
