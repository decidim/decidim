# frozen_string_literal: true

require "spec_helper"

describe "Admin manages participatory process components" do
  include_context "when admin administrating a participatory process"

  it_behaves_like "manage process components"

  describe "Soft delete" do
    let(:admin_resource_path) { decidim_admin_participatory_processes.components_path(participatory_process) }
    let(:trash_path) { decidim_admin_participatory_processes.manage_trash_components_path(participatory_process) }
    let(:title) { { en: "My component" } }
    let!(:participatory_space_title) { participatory_process.title["en"] }
    let!(:resource) { create(:component, manifest_name: "proposals", participatory_space: participatory_process, deleted_at:, name: title) }

    it_behaves_like "manage soft deletable component or space", "component"
    it_behaves_like "manage trashed resource", "component"
  end
end
