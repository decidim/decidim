# frozen_string_literal: true

require "spec_helper"

describe "Filter Assemblies" do
  let(:organization) { create(:organization) }

  before do
    switch_to_host(organization.host)
  end

  context "when filtering parent assemblies by assembly_type" do
    let!(:assemblies) { create_list(:assembly, 3, :with_type, organization:) }

    it "filters by All types" do
      visit decidim_assemblies.assemblies_path

      within "#dropdown-menu-filters div.filter-container", text: "Type" do
        check "All"
      end
      within "#assemblies-grid" do
        expect(page).to have_css(".card__grid", count: 3)
      end
    end

    3.times do |i|
      it "filters by Government type" do
        visit decidim_assemblies.assemblies_path

        assembly = assemblies[i]
        within "#dropdown-menu-filters div.filter-container", text: "Type" do
          check translated(assembly.assembly_type.title)
        end
        within "#assemblies-grid" do
          expect(page).to have_css(".card__grid", count: 1)
          expect(page).to have_content(translated(assembly.title))
        end
      end
    end

    it "filters by multiple types" do
      visit decidim_assemblies.assemblies_path

      within "#dropdown-menu-filters div.filter-container", text: "Type" do
        check translated(assemblies[0].assembly_type.title)
        check translated(assemblies[1].assembly_type.title)
      end
      within "#assemblies-grid" do
        expect(page).to have_css(".card__grid", count: 2)
        expect(page).to have_content(translated(assemblies[0].title))
        expect(page).to have_content(translated(assemblies[1].title))
        expect(page).to have_no_content(translated(assemblies[2].title))
      end
    end
  end

  context "when no assemblies types present" do
    let!(:assemblies) { create_list(:assembly, 3, organization:) }

    before do
      visit decidim_assemblies.assemblies_path
    end

    it "does not show the assemblies types filter" do
      expect(page).to have_no_css("#dropdown-menu-filters div.filter-container", text: "Type")
    end
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
        visit decidim_assemblies.assemblies_path(filter: { with_any_taxonomies: { taxonomy.parent_id => [taxonomy.id] } })
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
