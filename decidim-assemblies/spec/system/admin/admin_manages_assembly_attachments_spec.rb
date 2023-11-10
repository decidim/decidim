# frozen_string_literal: true

require "spec_helper"

describe "Admin manages assembly attachments" do
  include_context "when admin administrating an assembly"

  let(:attached_to) { assembly }
  let(:attachment_collection) { create(:attachment_collection, collection_for: assembly) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_assemblies.edit_assembly_path(assembly)
    within_admin_sidebar_menu do
      click_link "Attachments"
    end
  end

  it_behaves_like "manage attachments examples"
end
