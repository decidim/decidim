# frozen_string_literal: true

require "spec_helper"

describe "Admin manages participatory process soft delete" do
  let!(:user) { create(:user, :admin, :confirmed, organization:) }
  let(:organization) { create(:organization) }
  let(:admin_resource_path) { decidim_admin_participatory_processes.participatory_processes_path }
  let(:trash_path) { decidim_admin_participatory_processes.manage_trash_participatory_processes_path }
  let(:title) { { en: "My space" } }
  let!(:resource) { create(:participatory_process, title:, organization:) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit admin_resource_path
  end

  it_behaves_like "manage soft deletable component or space", "participatory process"
  it_behaves_like "manage trashed resource", "participatory process"

  context "when a user is collaborator" do
    let!(:participatory_process) { create(:participatory_process, organization:) }
    let!(:user) { create(:user, :admin_terms_accepted, :confirmed, organization:) }
    let!(:collaborator_role) do
      create(:participatory_process_user_role,
             user:,
             participatory_process:,
             role: :collaborator)
    end

    it "does not allow collaborators to view deleted processes" do
      expect(page).to have_text("Processes")
      expect(page).to have_no_link("View deleted processes", href: /.*processes.*trash.*/)
    end
  end

  context "when a user is evaluator" do
    let!(:participatory_process) { create(:participatory_process, organization:) }
    let!(:user) { create(:user, :admin_terms_accepted, :confirmed, organization:) }
    let!(:evaluator_role) do
      create(:participatory_process_user_role,
             user:,
             participatory_process:,
             role: :evaluator)
    end

    it "does not allow evaluators to view deleted processes" do
      expect(page).to have_text("Processes")
      expect(page).to have_no_link("View deleted processes", href: /.*processes.*trash.*/)
    end
  end

  context "when a user is moderator" do
    let!(:participatory_process) { create(:participatory_process, organization:) }
    let!(:user) { create(:user, :admin_terms_accepted, :confirmed, organization:) }
    let!(:moderator_role) do
      create(:participatory_process_user_role,
             user:,
             participatory_process:,
             role: :moderator)
    end

    it "does not allow moderators to view deleted processes" do
      expect(page).to have_text("Processes")
      expect(page).to have_no_link("View deleted processes", href: /.*processes.*trash.*/)
    end
  end

  context "when a user is a space admin" do
    let!(:participatory_process) { create(:participatory_process, organization:) }
    let!(:user) { create(:user, :admin_terms_accepted, :confirmed, organization:) }
    let!(:admin_role) do
      create(:participatory_process_user_role,
             user:,
             participatory_process:,
             role: :admin)
    end

    it "does not allow space admins to view deleted processes" do
      expect(page).to have_text("Processes")
      expect(page).to have_no_link("View deleted processes", href: /.*processes.*trash.*/)
    end
  end
end
