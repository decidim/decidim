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
      expect(page).to have_no_link("View deleted processes", href: /.*processes.*trash.*/)
    end
  end

  context "when a user is evaluator" do
    let!(:participatory_process) { create(:participatory_process, organization: organization) }
    let!(:evaluator_user) { create(:user, :admin_terms_accepted, :confirmed, organization: organization) }
    let!(:evaluator_role) do
      create(:participatory_process_user_role,
             user: evaluator_user,
             participatory_process: participatory_process,
             role: :valuator)
    end

    before do
      switch_to_host(organization.host)
      login_as evaluator_user, scope: :user
      visit admin_resource_path
    end

    it "does not allow evaluators to view deleted processes" do
      expect(page).to have_content("Processes")
      expect(page).to have_no_link("View deleted processes", href: /.*processes.*trash.*/)
    end
  end

  context "when a user is moderator" do
    let!(:participatory_process) { create(:participatory_process, organization: organization) }
    let!(:moderator_user) { create(:user, :admin_terms_accepted, :confirmed, organization: organization) }
    let!(:moderator_role) do
      create(:participatory_process_user_role,
             user: moderator_user,
             participatory_process: participatory_process,
             role: :moderator)
    end

    before do
      switch_to_host(organization.host)
      login_as moderator_user, scope: :user
      visit admin_resource_path
    end

    it "does not allow moderators to view deleted processes" do
      expect(page).to have_content("Processes")
      expect(page).to have_no_link("View deleted processes", href: /.*processes.*trash.*/)
    end
  end

  context "when a user is a space admin" do
    let!(:participatory_process) { create(:participatory_process, organization: organization) }
    let!(:admin_user) { create(:user, :admin_terms_accepted, :confirmed, organization: organization) }
    let!(:admin_role) do
      create(:participatory_process_user_role,
             user: admin_user,
             participatory_process: participatory_process,
             role: :admin)
    end

    before do
      switch_to_host(organization.host)
      login_as admin_user, scope: :user
      visit admin_resource_path
    end

    it "does not allow space admins to view deleted processes" do
      expect(page).to have_content("Processes")
      expect(page).to have_no_link("View deleted processes", href: /.*processes.*trash.*/)
    end
  end
end
