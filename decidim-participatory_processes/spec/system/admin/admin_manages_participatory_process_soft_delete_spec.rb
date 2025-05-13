# frozen_string_literal: true

require "spec_helper"

describe "Admin manages participatory process soft delete" do
  let!(:user) { create(:user, :admin, :confirmed, organization:) }
  let(:organization) { create(:organization) }
  let(:admin_resource_path) { decidim_admin_participatory_processes.participatory_processes_path }
  let(:trash_path) { decidim_admin_participatory_processes.manage_trash_participatory_processes_path }
  let(:title) { { en: "My space" } }
  let!(:resource) { create(:participatory_process, title:, organization:) }

  it_behaves_like "manage soft deletable component or space", "participatory process"
  it_behaves_like "manage trashed resource", "participatory process"

  context "when a user is collaborator" do
    let!(:participatory_process) { create(:participatory_process, organization: organization) }
    let!(:collaborator_user) { create(:user, :admin_terms_accepted, :confirmed, organization: organization) }
    let!(:collaborator_role) do
      create(:participatory_process_user_role,
             user: collaborator_user,
             participatory_process: participatory_process,
             role: :collaborator)
    end

    before do
      switch_to_host(organization.host)
      login_as collaborator_user, scope: :user
      visit admin_resource_path
    end

    it "does not allow collaborators to view deleted processes" do
      expect(page).to have_content("Processes")
      expect(page).to have_no_content("View deleted processes")
    end
  end
end
