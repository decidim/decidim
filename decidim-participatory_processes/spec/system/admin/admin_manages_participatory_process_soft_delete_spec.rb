# frozen_string_literal: true

require "spec_helper"

describe "Admin manages participatory process soft delete" do
  let!(:user) { create(:user, :admin, :confirmed, organization:) }
  let(:organization) { create(:organization) }
  let(:admin_resource_path) { decidim_admin_participatory_processes.participatory_processes_path }
  let(:trash_path) { decidim_admin_participatory_processes.deleted_participatory_processes_path }
  let(:title) { { en: "My space" } }
  let!(:resource) { create(:participatory_process, deleted_at:, title:, organization:) }

  it_behaves_like "manage soft deletable component or space", "participatory process"
  it_behaves_like "manage trashed resource", "participatory process"
end
