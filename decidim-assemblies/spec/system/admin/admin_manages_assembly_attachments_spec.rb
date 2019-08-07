# frozen_string_literal: true

require "spec_helper"

describe "Admin manages assembly attachments", type: :system do
  include_context "when admin administrating an assembly"

  let(:attached_to) { assembly }
  let(:attachment_collection) { create(:attachment_collection, collection_for: assembly) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_assemblies.edit_assembly_path(assembly)
    click_link "Files"
  end

  it_behaves_like "manage attachments examples"
end
