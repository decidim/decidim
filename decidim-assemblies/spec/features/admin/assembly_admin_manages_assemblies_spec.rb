# frozen_string_literal: true

require "spec_helper"

describe "Assembly admin manages assemblies", type: :feature do
  include_context "when assembly admin administrating an assembly"

  it_behaves_like "manage assemblies"

  it "cannot create a new assembly" do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_assemblies.assemblies_path

    expect(page).to have_no_selector(".actions .new")
  end

  context "when deleting an assembly" do
    let!(:assembly2) { create(:assembly, organization: organization) }
    let!(:process_user_role2) { create :assembly_user_role, user: user, assembly: assembly2 }

    before do
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit decidim_admin_assemblies.assemblies_path
    end

    it "cannot delete an assembly" do
      within find("tr", text: translated(assembly2.title)) do
        expect(page).to have_no_content("Destroy")
      end
    end
  end
end
