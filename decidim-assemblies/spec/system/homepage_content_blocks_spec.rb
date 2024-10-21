# frozen_string_literal: true

require "spec_helper"

describe "Homepage assemblies content blocks" do
  let(:organization) { create(:organization) }
  let!(:promoted_assembly) { create(:assembly, :promoted, organization:) }
  let!(:unpromoted_assembly) { create(:assembly, organization:) }
  let!(:promoted_external_assembly) { create(:assembly, :promoted) }
  let!(:highlighted_assemblies_content_block) { create(:content_block, organization:, scope_name: :homepage, manifest_name: :highlighted_assemblies) }

  include_context "when admin administrating an assembly"

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  it "includes active assemblies to the homepage" do
    visit decidim.root_path

    within "#highlighted-assemblies" do
      expect(page).to have_i18n_content(promoted_assembly.title)
      expect(page).to have_i18n_content(unpromoted_assembly.title)
      expect(page).not_to have_i18n_content(promoted_external_assembly.title)
    end
  end

  it "updates the settings of the content block" do
    visit decidim_admin.edit_organization_homepage_content_block_path(highlighted_assemblies_content_block)

    expect(find("input[type='number'][name='content_block[settings][max_results]").value).to eq("6")

    fill_in "content_block[settings][max_results]", with: "1"
    click_on "Update"

    expect(page).to have_content("Highlighted assemblies")
    expect(highlighted_assemblies_content_block.reload.settings["max_results"]).to eq(1)

    visit decidim.root_path

    within "#highlighted-assemblies" do
      expect(page).to have_css("a.card__grid", count: 1)
    end
  end
end
