# frozen_string_literal: true

require "spec_helper"

describe "Admin manages assembly admins" do
  include_context "when admin administrating an assembly"

  it_behaves_like "manage assembly admins examples"

  context "when visiting as space admin" do
    let!(:user) do
      create(:assembly_admin,
             :confirmed,
             organization:,
             assembly:)
    end

    before do
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit decidim_admin_assemblies.edit_assembly_path(assembly)
      within_admin_sidebar_menu do
        click_on "Assembly admins"
      end
    end

    it "shows assembly admin list" do
      within "#assembly_admins table" do
        expect(page).to have_content(user.email)
      end
    end
  end
end
