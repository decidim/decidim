# frozen_string_literal: true

require "spec_helper"

describe "Admin checks pagination on participatory space private users", type: :system do
  let(:organization) { create(:organization) }

  let!(:user) { create(:user, :admin, :confirmed, organization: organization) }
  let(:assembly) { create(:assembly, organization: organization) }

  before do
    (0..20).each do |_i|
      user = create :user, organization: organization
      create :assembly_private_user, user: user, privatable_to: assembly
    end
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_assemblies.edit_assembly_path(assembly)
    find("a[href*='participatory_space_private_users']").click
  end

  it "shows private users of the participatory space and changes page correctly" do
    find("li a", text: "Next").click
  end
end
