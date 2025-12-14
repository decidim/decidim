# frozen_string_literal: true

require "spec_helper"

describe "Initiatives Breadcrumb" do
  let(:organization) { create(:organization) }
  let(:participatory_space) { create(:initiative, :open, organization:) }
  let(:component) { create(:meeting_component, :published, participatory_space:) }
  let(:router) { Decidim::EngineRouter.main_proxy(component) }
  let!(:meeting) { create(:meeting, :published, component:) }

  before do
    switch_to_host(organization.host)
  end

  scenario "shows breadcrumb with only initiative" do
    visit decidim_initiatives.initiative_path(participatory_space, locale: I18n.locale)

    within ".menu-bar" do
      expect(page).to have_content("Initiatives")
      expect(page).to have_content(translated(participatory_space.title))
    end
  end

  scenario "shows breadcrumb with initiative and component" do
    visit router.root_path

    within ".menu-bar" do
      expect(page).to have_content("Initiatives")
      expect(page).to have_content(translated(participatory_space.title))
      expect(page).to have_content(translated(component.name))
    end
  end
end
