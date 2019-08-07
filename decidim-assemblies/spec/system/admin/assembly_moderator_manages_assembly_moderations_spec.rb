# frozen_string_literal: true

require "spec_helper"

describe "Assembly moderator manages assembly moderations", type: :system do
  include_context "when assembly moderator administrating an assembly"

  let(:current_component) { create :component, participatory_space: assembly }
  let!(:reportables) { create_list(:dummy_resource, 2, component: current_component) }
  let(:participatory_space_path) do
    decidim_admin_assemblies.moderations_path(assembly)
  end

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  it_behaves_like "manage moderations"
end
