# frozen_string_literal: true

require "spec_helper"

describe "Admin manages assembly publication", type: :system do
  include_context "when admin administrating an assembly"

  let(:admin_page_path) { decidim_admin_assemblies.edit_assembly_path(participatory_space) }
  let(:public_collection_path) { decidim_assemblies.assemblies_path }
  let(:title) { "My space" }
  let!(:participatory_space) { assembly }

  it_behaves_like "manage participatory space publications"
end
