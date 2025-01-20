# frozen_string_literal: true

require "spec_helper"

describe "Filter Assemblies" do
  let(:organization) { create(:organization) }

  before do
    switch_to_host(organization.host)
  end

  context "when filtering parent assemblies by taxonomies" do
    let!(:taxonomy) { create(:taxonomy, :with_parent, organization:) }
    let!(:assembly_with_taxonomy) { create(:assembly, taxonomies: [taxonomy], organization:) }
    let!(:assembly_without_taxonomy) { create(:assembly, organization:) }

    context "and choosing a taxonomy" do
      before do
        visit decidim_assemblies.assemblies_path(filter: { with_any_taxonomies: { taxonomy.parent_id => [taxonomy.id] } })
      end

      it "lists all processes belonging to that taxonomy" do
        within "#assemblies-grid" do
          expect(page).to have_content(translated(assembly_with_taxonomy.title))
          expect(page).to have_no_content(translated(assembly_without_taxonomy.title))
        end
      end
    end
  end
end
