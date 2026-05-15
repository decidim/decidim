# frozen_string_literal: true

require "spec_helper"

describe "Meetings Breadcrumb" do
  include_context "with a component"
  let(:manifest_name) { "meetings" }

  let!(:meeting) { create(:meeting, :published, component:) }

  before do
    stub_geocoding_coordinates([meeting.latitude, meeting.longitude])
    visit_component
  end

  describe "index" do
    it "shows the correct information in breadcrumb (space, component)" do
      within(".menu-bar") do
        expect(page).to have_content(translated(component.participatory_space.title))
        expect(page).to have_content(translated(component.name))
      end
    end
  end

  describe "show" do
    it "shows the correct information in breadcrumb (space, component, meeting)" do
      click_on meeting.title[I18n.locale.to_s]
      within(".menu-bar") do
        expect(page).to have_content(translated(component.participatory_space.title))
        expect(page).to have_content(translated(component.name))
        expect(page).to have_content(translated(meeting.title))
      end
    end
  end

  describe "versions", versioning: true do
    let(:meeting_path) do
      decidim_participatory_process_meetings.meeting_path(
        participatory_process_slug: participatory_process.slug,
        component_id: component.id,
        id: meeting.id
      )
    end

    before do
      stub_geocoding_coordinates([meeting.latitude, meeting.longitude])
      Decidim.traceability.update!(
        meeting,
        "test suite",
        title: { en: "My updated title" }
      )
      visit meeting_path
      click_on "see other versions"
    end

    it "shows the correct information in breadcrumb (space, component, meeting)" do
      within(".menu-bar") do
        expect(page).to have_content(translated(component.participatory_space.title))
        expect(page).to have_content(translated(component.name))
        expect(page).to have_content(translated(meeting.title))
      end
    end
  end
end
