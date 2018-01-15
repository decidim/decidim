# frozen_string_literal: true

require "spec_helper"

describe "Assembly admin manages assembly moderations", type: :feature do
  include_context "when assembly admin administrating an assembly"

  let(:current_feature) { create :feature, participatory_space: assembly }
  let!(:reportables) { create_list(:dummy_resource, 2, feature: current_feature) }
  let(:participatory_space_path) do
    decidim_admin_assemblies.edit_assembly_path(assembly)
  end

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  it_behaves_like "manage moderations"
end
