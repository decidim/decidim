# frozen_string_literal: true

require "spec_helper"

describe "Filter Assemblies" do
  let(:organization) { create(:organization) }

  before do
    switch_to_host(organization.host)
  end

  context "when filtering parent assemblies by taxonomies" do
    let!(:taxonomy) { create(:taxonomy, :with_parent, organization:, name: { en: "A great taxonomy" }) }
    let!(:another_taxonomy) { create(:taxonomy, parent: taxonomy.parent, organization:, name: { en: "Another taxonomy" }) }
    let!(:assembly_with_taxonomy) { create(:assembly, taxonomies: [taxonomy], organization:) }
    let!(:assembly_without_taxonomy) { create(:assembly, organization:) }
    let(:taxonomy_filter) { create(:taxonomy_filter, root_taxonomy: taxonomy.parent, participatory_space_manifests:) }
    let(:external_taxonomy_filter) { create(:taxonomy_filter, :with_items, participatory_space_manifests:) }
    let(:participatory_space_manifests) { ["assemblies"] }
    let!(:taxonomy_filter_item) { create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: taxonomy) }
    let!(:another_taxonomy_filter_item) { create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: another_taxonomy) }

    context "and choosing a taxonomy" do
      before do
        visit decidim_assemblies.assemblies_path(filter: { with_any_taxonomies: { taxonomy.parent_id => [taxonomy.id] } }, locale: I18n.locale)
      end

      it "lists all assemblies belonging to that taxonomy" do
        within "#assemblies-grid" do
          expect(page).to have_content(translated(assembly_with_taxonomy.title))
          expect(page).to have_no_content(translated(assembly_without_taxonomy.title))
        end

        within "#panel-dropdown-menu-taxonomy" do
          click_filter_item "Another taxonomy"
          sleep 2
        end

        within "#assemblies-grid" do
          expect(page).to have_no_content(translated(assembly_with_taxonomy.title))
          expect(page).to have_no_content(translated(assembly_without_taxonomy.title))
        end

        within "#panel-dropdown-menu-taxonomy" do
          click_filter_item "Another taxonomy"
          sleep 2
        end

        within "#assemblies-grid" do
          expect(page).to have_content(translated(assembly_with_taxonomy.title))
          expect(page).to have_content(translated(assembly_without_taxonomy.title))
        end
      end
    end
  end
end
