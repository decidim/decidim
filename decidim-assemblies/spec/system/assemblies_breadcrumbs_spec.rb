# frozen_string_literal: true

require "spec_helper"

describe "Assemblies Breadcrumb" do
  let(:organization) { create(:organization) }
  let(:parent_assembly) { create(:assembly, :published, organization:) }
  let(:child_assembly) { create(:assembly, :published, organization:, parent: parent_assembly) }
  let(:component) { create(:proposal_component, :published, participatory_space: child_assembly) }
  let(:router) { Decidim::EngineRouter.main_proxy(component) }
  let!(:proposal) { create(:proposal, :published, component:) }

  before do
    switch_to_host(organization.host)
    child_assembly.update!(parent: parent_assembly)
  end

  context "when viewing a child assembly page" do
    scenario "shows breadcrumb with parent assembly and child assembly" do
      visit decidim_assemblies.assembly_path(child_assembly)

      within ".menu-bar" do
        expect(page).to have_content("Assemblies")
        expect(page).to have_content(translated(parent_assembly.title))
        expect(page).to have_content(translated(child_assembly.title))
      end
    end
  end

  context "when viewing a component page within a child assembly" do
    scenario "shows breadcrumb with parent assembly, child assembly, and component" do
      visit router.root_path

      within ".menu-bar" do
        expect(page).to have_content("Assemblies")
        expect(page).to have_content(translated(parent_assembly.title))
        expect(page).to have_content(translated(child_assembly.title))
        expect(page).to have_content(translated(component.name))
      end
    end

    scenario "shows breadcrumb with parent assembly, child assembly, and component on component sub-pages" do
      visit router.proposal_path(proposal)

      within ".menu-bar" do
        expect(page).to have_content("Assemblies")
        expect(page).to have_content(translated(parent_assembly.title))
        expect(page).to have_content(translated(child_assembly.title))
        expect(page).to have_content(translated(component.name))
      end
    end
  end

  context "when viewing a parent assembly page" do
    scenario "shows breadcrumb with only parent assembly" do
      visit decidim_assemblies.assembly_path(parent_assembly)

      within ".menu-bar" do
        expect(page).to have_content("Assemblies")
        expect(page).to have_content(translated(parent_assembly.title))
        expect(page).to have_no_content(translated(child_assembly.title))
      end
    end
  end

  context "when viewing a component page within a parent assembly" do
    let(:component) { create(:component, manifest_name: "proposals", participatory_space: parent_assembly) }
    let!(:proposal) { create(:proposal, component:) }

    scenario "shows breadcrumb with parent assembly and component" do
      visit router.root_path

      within ".menu-bar" do
        expect(page).to have_content("Assemblies")
        expect(page).to have_content(translated(parent_assembly.title))
        expect(page).to have_content(translated(component.name))
        expect(page).to have_no_content(translated(child_assembly.title))
      end
    end
  end

  context "when viewing an assembly without parent" do
    let(:standalone_assembly) { create(:assembly, :published, organization:) }
    let(:component) { create(:component, manifest_name: "proposals", participatory_space: standalone_assembly) }

    scenario "shows breadcrumb with only assembly" do
      visit decidim_assemblies.assembly_path(standalone_assembly)

      within ".menu-bar" do
        expect(page).to have_content("Assemblies")
        expect(page).to have_content(translated(standalone_assembly.title))
        expect(page).to have_no_content(translated(parent_assembly.title))
      end
    end

    scenario "shows breadcrumb with assembly and component" do
      visit router.root_path

      within ".menu-bar" do
        expect(page).to have_content("Assemblies")
        expect(page).to have_content(translated(standalone_assembly.title))
        expect(page).to have_content(translated(component.name))
        expect(page).to have_no_content(translated(parent_assembly.title))
      end
    end
  end
end
