# frozen_string_literal: true

require "spec_helper"

describe "Admin checks pagination on participatory space private users" do
  let(:organization) { create(:organization) }

  let!(:user) { create(:user, :admin, :confirmed, organization:) }
  let(:assembly) { create(:assembly, organization:, private_space: true) }

  let!(:private_users) { create_list(:assembly_private_user, 26, privatable_to: assembly, user: create(:user, organization: assembly.organization)) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_assemblies.edit_assembly_path(assembly)
    within_admin_sidebar_menu do
      click_on "Members"
    end
  end

  it "shows private users of the participatory space and changes page correctly" do
    find("li a", text: "Next").click
    expect(page).to have_current_path "#{decidim_admin_assemblies.participatory_space_private_users_path(assembly_slug: assembly.slug)}?page=2"
  end
end
