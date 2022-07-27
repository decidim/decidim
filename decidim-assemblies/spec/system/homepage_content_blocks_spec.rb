# frozen_string_literal: true

require "spec_helper"

describe "Homepage assemblies content blocks", type: :system do
  let(:organization) { create(:organization) }
  let(:show_statistics) { true }
  let!(:promoted_assembly) { create(:assembly, :promoted, organization:) }
  let!(:unpromoted_assembly) { create(:assembly, organization:) }
  let!(:promoted_external_assembly) { create(:assembly, :promoted) }

  before do
    create :content_block, organization: organization, scope_name: :homepage, manifest_name: :highlighted_assemblies
    switch_to_host(organization.host)
  end

  it "includes active assemblies to the homepage" do
    visit decidim.root_path

    within "#highlighted-assemblies" do
      expect(page).to have_i18n_content(promoted_assembly.title)
      expect(page).to have_i18n_content(unpromoted_assembly.title)
      expect(page).not_to have_i18n_content(promoted_external_assembly.title)
    end
  end
end
