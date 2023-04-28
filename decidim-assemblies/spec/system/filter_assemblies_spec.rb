# frozen_string_literal: true

require "spec_helper"

describe "Filter Assemblies", type: :system do
  let(:organization) { create(:organization) }

  before do
    switch_to_host(organization.host)
  end

  context "when filtering parent assemblies by assembly_type" do
    let!(:assemblies) { create_list(:assembly, 3, :with_type, organization:) }

    before do
      visit decidim_assemblies.assemblies_path
    end

    it "filters by All types" do
      within "#dropdown-menu-filters div.filter-container", text: "Type" do
        check "All"
      end
      within "#assemblies-grid" do
        expect(page).to have_selector(".card__grid", count: 3)
      end
    end

    3.times do |i|
      it "filters by Government type" do
        assembly = assemblies[i]
        within "#dropdown-menu-filters div.filter-container", text: "Type" do
          check assembly.assembly_type.title["en"]
        end
        within "#assemblies-grid" do
          expect(page).to have_selector(".card__grid", count: 1)
          expect(page).to have_content(translated(assembly.title))
        end
      end
    end
  end

  context "when no assemblies types present" do
    let!(:assemblies) { create_list(:assembly, 3, organization:) }

    before do
      visit decidim_assemblies.assemblies_path
    end

    it "does not show the assemblies types filter" do
      within("#dropdown-menu-filters") do
        expect(page).to have_no_css("#dropdown-menu-filters div.filter-container", text: "Type")
      end
    end
  end

  context "when filtering parent assemblies by scope" do
    let!(:scope) { create :scope, organization: }
    let!(:assembly_with_scope) { create(:assembly, scope:, organization:) }
    let!(:assembly_without_scope) { create(:assembly, organization:) }

    context "and choosing a scope" do
      before do
        visit decidim_assemblies.assemblies_path(filter: { with_scope: scope.id })
      end

      it "lists all processes belonging to that scope" do
        within "#assemblies-grid" do
          expect(page).to have_content(translated(assembly_with_scope.title))
          expect(page).to have_no_content(translated(assembly_without_scope.title))
        end
      end
    end
  end

  context "when filtering parent assemblies by area" do
    let!(:area) { create :area, organization: }
    let!(:assembly_with_area) { create(:assembly, area:, organization:) }
    let!(:assembly_without_area) { create(:assembly, organization:) }

    before do
      visit decidim_assemblies.assemblies_path
    end

    context "and choosing an area" do
      before do
        skip "REDESIGN_PENDING - This test fails with redesigned filters using checkboxes. The issue is addressed in https://github.com/decidim/decidim/issues/10801"

        within "#dropdown-menu-filters div.filter-container", text: "Area" do
          check translated(area.name)
        end
      end

      it "lists all processes belonging to that area" do
        within "#assemblies-grid" do
          expect(page).to have_content(translated(assembly_with_area.title))
          expect(page).not_to have_content(translated(assembly_without_area.title))
        end
      end
    end
  end
end
