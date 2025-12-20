# frozen_string_literal: true

require "spec_helper"

describe "Conferences Breadcrumb" do
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

  describe "with a program" do
    let(:meetings_component) { create(:meeting_component, :published, participatory_space:) }
    let!(:meeting) { create(:meeting, :published, component: meetings_component, start_time: 1.day.from_now) }

    scenario "shows breadcrumb with conference and program" do
      visit decidim_conferences.conference_conference_program_path(participatory_space, meetings_component, locale: I18n.locale)

      within ".menu-bar" do
        expect(page).to have_content("Conferences")
        expect(page).to have_content(translated(participatory_space.title))
        expect(page).to have_content("Program")
      end
    end

    scenario "shows breadcrumb with conference, program, and meeting" do
      visit decidim_conferences.conference_conference_program_path(participatory_space, meetings_component, locale: I18n.locale)
      click_on decidim_sanitize_translated(meeting.title)

      within ".menu-bar" do
        expect(page).to have_content("Conferences")
        expect(page).to have_content(translated(participatory_space.title))
        expect(page).to have_content("Program")
        expect(page).to have_content(translated_attribute(meeting.title))
      end
    end
  end
end
