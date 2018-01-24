# frozen_string_literal: true

require "spec_helper"

describe "Assembly admin manages assembly admins", type: :system do
  include_context "when assembly admin administrating an assembly"

  it_behaves_like "manage assembly admins examples"

  context "when removing himself from the list" do
    before do
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit decidim_admin_assemblies.edit_assembly_path(assembly)
      click_link "Assembly users"
    end

    it "cannot remove himself" do
      within find("#assembly_admins tr", text: user.email) do
        expect(page).to have_no_content("Destroy")
      end
    end
  end
end
