# frozen_string_literal: true

require "spec_helper"
require "decidim/admin/test/manage_attachment_collections_examples"

describe "Admin manages assembly attachment collections examples", type: :system do
  include_context "when administrating an assembly"

  let(:participatory_space) { assembly }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_assemblies.edit_assembly_path(assembly)
    click_link "Collections"
  end

  it_behaves_like "manage attachment collections examples"
end
