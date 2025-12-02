# frozen_string_literal: true

require "spec_helper"

describe "Participatory Process Breadcrumb" do
  let(:organization) { create(:organization) }
  let(:participatory_space) { create(:participatory_process, :published, organization:) }
  let(:component) { create(:proposal_component, :published, participatory_space:) }
  let(:router) { Decidim::EngineRouter.main_proxy(component) }
  let!(:proposal) { create(:proposal, :published, component:) }

  before do
    switch_to_host(organization.host)
  end

  context "when there is a participatory process group" do
    let!(:participatory_process_group) { create(:participatory_process_group, :with_participatory_processes, organization:) }
    let(:participatory_space) { participatory_process_group.participatory_processes.first }

    scenario "shows breadcrumb with only participatory process group" do
      visit decidim_participatory_processes.participatory_process_group_path(participatory_process_group)

      within ".menu-bar" do
        expect(page).to have_content("Processes")
        expect(page).to have_content(translated(participatory_process_group.title))
      end
    end

    scenario "shows breadcrumb with participatory process group and participatory process" do
      visit decidim_participatory_processes.participatory_process_path(participatory_space)

      within ".menu-bar" do
        expect(page).to have_content("Processes")
        expect(page).to have_content(translated(participatory_process_group.title))
        expect(page).to have_content(translated(participatory_space.title))
      end
    end

    scenario "shows breadcrumb with participatory process group, participatory process and component" do
      visit router.root_path

      within ".menu-bar" do
        expect(page).to have_content("Processes")
        expect(page).to have_content(translated(participatory_process_group.title))
        expect(page).to have_content(translated(participatory_space.title))
        expect(page).to have_content(translated(component.name))
      end
    end
  end

  context "when there is a participatory process" do
    scenario "shows breadcrumb with only participatory process" do
      visit decidim_participatory_processes.participatory_process_path(participatory_space)

      within ".menu-bar" do
        expect(page).to have_content("Processes")
        expect(page).to have_content(translated(participatory_space.title))
      end
    end

    scenario "shows breadcrumb with participatory process and component" do
      visit router.root_path

      within ".menu-bar" do
        expect(page).to have_content("Processes")
        expect(page).to have_content(translated(participatory_space.title))
        expect(page).to have_content(translated(component.name))
      end
    end
  end
end
