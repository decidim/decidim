# frozen_string_literal: true

require "spec_helper"

describe "Filter Assemblies", type: :system do
  let(:organization) { create(:organization) }

  before do
    switch_to_host(organization.host)
  end

  context "when filtering parent assemblies by assembly_type" do
    let!(:assembly_1) { create(:assembly, organization: organization, assembly_type: "others") }
    let!(:assembly_2) { create(:assembly, organization: organization, assembly_type: "government") }
    let!(:assembly_3) { create(:assembly, organization: organization, assembly_type: "consultative_advisory") }
    let!(:assembly_4) { create(:assembly, organization: organization, assembly_type: "participatory") }
    let!(:assembly_5) { create(:assembly, organization: organization, assembly_type: "executive") }
    let!(:assembly_6) { create(:assembly, organization: organization, assembly_type: "working_group") }
    let!(:assembly_7) { create(:assembly, organization: organization, assembly_type: "commission") }

    before do
      visit decidim_assemblies.assemblies_path
      click_button "All types of assemblies"
    end

    it "filters by All types" do
      click_link "All types of assemblies"
      expect(page).to have_selector("article.card.card--assembly", count: 7)
    end

    it "filters by Government type" do
      click_link "Government"
      expect(page).to have_selector("article.card.card--assembly", count: 1)
      expect(page).to have_selector("#button-text", text: "Government")
    end

    it "filters by Executive type" do
      click_link "Executive"
      expect(page).to have_selector("article.card.card--assembly", count: 1)
      expect(page).to have_selector("#button-text", text: "Executive")
    end

    it "filters by Consultative/Advisory type" do
      click_link "Consultative/Advisory"
      expect(page).to have_selector("article.card.card--assembly", count: 1)
      expect(page).to have_selector("#button-text", text: "Consultative/Advisory")
    end

    it "filters by Participatory type" do
      click_link "Participatory"
      expect(page).to have_selector("article.card.card--assembly", count: 1)
      expect(page).to have_selector("#button-text", text: "Participatory")
    end

    it "filters by Working group type" do
      click_link "Working group"
      expect(page).to have_selector("article.card.card--assembly", count: 1)
      expect(page).to have_selector("#button-text", text: "Working group")
    end

    it "filters by Commission type" do
      click_link "Commission"
      expect(page).to have_selector("article.card.card--assembly", count: 1)
      expect(page).to have_selector("#button-text", text: "Commission")
    end

    it "filters by Others type" do
      click_link "Others"
      expect(page).to have_selector("article.card.card--assembly", count: 1)
      expect(page).to have_selector("#button-text", text: "Others")
    end
  end

  context "when filtering parent assemblies by scope" do
    let!(:scope) { create :scope, organization: organization }
    let!(:assembly_with_scope) { create(:assembly, scope: scope, organization: organization) }
    let!(:assembly_without_scope) { create(:assembly, organization: organization) }

    context "and choosing a scope" do
      before do
        visit decidim_assemblies.assemblies_path(filter: { scope_id: scope.id })
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
    let!(:area) { create :area, organization: organization }
    let!(:assembly_with_area) { create(:assembly, area: area, organization: organization) }
    let!(:assembly_without_area) { create(:assembly, organization: organization) }

    before do
      visit decidim_assemblies.assemblies_path
    end

    context "and choosing an area" do
      before do
        select translated(area.name), from: "filter[area_id]"
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
