# frozen_string_literal: true

require "spec_helper"

describe "Admin manages assembly attachments", type: :feature do
  include_context "when administrating an assembly"

  let(:attached_to) { assembly }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_assemblies.edit_assembly_path(assembly)
    click_link "Attachments"
  end

  it_behaves_like "manage attachments examples"
end
