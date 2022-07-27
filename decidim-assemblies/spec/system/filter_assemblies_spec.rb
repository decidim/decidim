# frozen_string_literal: true

require "spec_helper"

describe "Filter Assemblies", type: :system do
  let(:organization) { create(:organization) }

  before do
    switch_to_host(organization.host)
  end

  context "when filtering parent assemblies by assembly_type" do
    # let!(:assembly_types) { create_list(:assemblies_type, 3, organization: organization) }
    let!(:assemblies) { create_list(:assembly, 3, :with_type, organization:) }

    before do
      visit decidim_assemblies.assemblies_path
      click_button "All types"
    end

    it "filters by All types" do
      click_link "All types"
      expect(page).to have_selector(".card.card--assembly", count: 3)
    end

    3.times do |i|
      it "filters by Government type" do
        assembly = assemblies[i]
        click_link assembly.assembly_type.title["en"]
        expect(page).to have_selector(".card.card--assembly", count: 1)
        expect(page).to have_selector("#button-text", text: assembly.assembly_type.title["en"])
      end
    end
  end

  context "when no assemblies types present" do
    let!(:assemblies) { create_list(:assembly, 3, organization:) }

    before do
      visit decidim_assemblies.assemblies_path
    end

    it "doesn't show the assemblies types filter" do
      within("#assemblies-filter") do
        expect(page).to have_no_content("All types")
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
        within "#parent-assemblies" do
          expect(page).to have_content(translated(assembly_with_scope.title))
          expect(page).not_to have_content(translated(assembly_without_scope.title))
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
        select translated(area.name), from: "filter[with_area]"
      end

      it "lists all processes belonging to that area" do
        within "#parent-assemblies" do
          expect(page).to have_content(translated(assembly_with_area.title))
          expect(page).not_to have_content(translated(assembly_without_area.title))
        end
      end
    end
  end
end
