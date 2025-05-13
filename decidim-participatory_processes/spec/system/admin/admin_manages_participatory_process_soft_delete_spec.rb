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

  describe "trashed participatory process" do
    let(:trashed_resource) { create(:participatory_process, :trashed, title:, organization:) }
    let!(:collaborator_role) { create(:participatory_process_user_role, role: :collaborator) }

    before do
      visit current_path
    end

    it "doesn't show the deleted processes path" do
      expect(page).to have_no_content(translated(trashed_resource.title))
    end
  end
end
