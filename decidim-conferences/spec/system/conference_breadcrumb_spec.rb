# frozen_string_literal: true

require "spec_helper"

describe "Conference Breadcrumb" do
  let(:organization) { create(:organization) }
  let(:participatory_space) { create(:conference, :published, organization:) }
  let(:component) { create(:proposal_component, :published, participatory_space:) }
  let(:router) { Decidim::EngineRouter.main_proxy(component) }
  let!(:proposal) { create(:proposal, :published, component:) }

  before do
    switch_to_host(organization.host)
  end

  scenario "shows breadcrumb with only conference" do
    visit decidim_conferences.conference_path(participatory_space, locale: I18n.locale)

    within ".menu-bar" do
      expect(page).to have_content("Conferences")
      expect(page).to have_content(translated(participatory_space.title))
    end
  end

  scenario "shows breadcrumb with conference and component" do
    visit router.root_path

    within ".menu-bar" do
      expect(page).to have_content("Conferences")
      expect(page).to have_content(translated(participatory_space.title))
      expect(page).to have_content(translated(component.name))
    end
  end
end
