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
        expect(page).to have_selector(".card__grid", count: 3)
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
          expect(page).to have_selector(".card__grid", count: 1)
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
        expect(page).to have_selector(".card__grid", count: 2)
        expect(page).to have_content(translated(assemblies[0].title))
        expect(page).to have_content(translated(assemblies[1].title))
        expect(page).not_to have_content(translated(assemblies[2].title))
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
        expect(page).not_to have_css("#dropdown-menu-filters div.filter-container", text: "Type")
      end
    end
  end

  context "when filtering parent assemblies by scope" do
    let!(:scope) { create(:scope, organization:) }
    let!(:assembly_with_scope) { create(:assembly, scope:, organization:) }
    let!(:assembly_without_scope) { create(:assembly, organization:) }

    context "and choosing a scope" do
      before do
        visit decidim_assemblies.assemblies_path(filter: { with_any_scope: [scope.id] })
      end

      it "lists all processes belonging to that scope" do
        within "#assemblies-grid" do
          expect(page).to have_content(translated(assembly_with_scope.title))
          expect(page).not_to have_content(translated(assembly_without_scope.title))
        end
      end
    end
  end

  context "when filtering parent assemblies by area" do
    let!(:area) { create(:area, organization:) }
    let!(:assembly_with_area) { create(:assembly, area:, organization:) }
    let!(:assembly_without_area) { create(:assembly, organization:) }

    context "and choosing an area" do
      before do
        visit decidim_assemblies.assemblies_path

        within "#dropdown-menu-filters div.filter-container", text: "Area" do
          check translated(area.name)
        end
      end

      it "enables the all option and lists all processes" do
        within "#assemblies-grid" do
          expect(page).to have_content(translated(assembly_with_area.title))
          expect(page).to have_content(translated(assembly_without_area.title))
        end
      end
    end

    context "when there are more than two areas" do
      let!(:other_area) { create(:area, organization:) }
      let!(:other_area_without_assemblies) { create(:area, organization:) }
      let!(:assembly_with_other_area) { create(:assembly, area: other_area, organization:) }

      context "and choosing an area" do
        before do
          visit decidim_assemblies.assemblies_path

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

      context "and choosing two areas with assemblies" do
        before do
          visit decidim_assemblies.assemblies_path

          within "#dropdown-menu-filters div.filter-container", text: "Area" do
            check translated(area.name)
            check translated(other_area.name)
          end
        end

        it "lists all processes belonging to both areas" do
          within "#assemblies-grid" do
            expect(page).to have_content(translated(assembly_with_area.title))
            expect(page).to have_content(translated(assembly_with_other_area.title))
            expect(page).not_to have_content(translated(assembly_without_area.title))
          end
        end
      end
    end
  end
end
