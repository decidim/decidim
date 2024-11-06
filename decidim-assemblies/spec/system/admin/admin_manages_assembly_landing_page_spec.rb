# frozen_string_literal: true

require "spec_helper"

describe "Admin manages assembly landing page" do
  include_context "when admin administrating an assembly"
  let!(:resource) { assembly }
  let(:scope_name) { :assembly_homepage }
  let(:edit_landing_page_path) { decidim_admin_assemblies.edit_assembly_landing_page_path(resource) }

  def edit_content_block_path(resource, content_block)
    decidim_admin_assemblies.edit_assembly_landing_page_content_block_path(resource, content_block)
  end

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  context "when editing related assemblies" do
    let!(:related_assemblies_content_block) { create(:content_block, organization:, scope_name: "assembly_homepage", manifest_name: "related_assemblies", scoped_resource_id: resource.id, settings: { "max_results" => "6" }) }

    it "updates the related assemblies content block" do
      visit edit_content_block_path(resource, related_assemblies_content_block)

      expect(related_assemblies_content_block.settings["max_results"]).to eq(6)
      fill_in :content_block_settings_max_results, with: "12"
      click_on "Update"

      expect(page).to have_content("Related assemblies")
      expect(related_assemblies_content_block.reload.settings["max_results"]).to eq(12)
    end
  end
end
