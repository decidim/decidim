# frozen_string_literal: true

require "spec_helper"

describe "Admin manages assembly components" do
  include_context "when admin administrating an assembly"

  it_behaves_like "manage assembly components"

  describe "Soft delete" do
    let(:admin_resource_path) { decidim_admin_assemblies.components_path(assembly) }
    let(:trash_path) { decidim_admin_assemblies.manage_trash_components_path(assembly) }
    let(:title) { { en: "My component" } }
    let!(:resource) { create(:component, manifest_name: "proposals", participatory_space: assembly, name: title) }

    it_behaves_like "manage soft deletable component or space", "component"
    it_behaves_like "manage trashed resource", "component"
  end
end
