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
    visit decidim_conferences.conference_path(participatory_space)

    within ".menu-bar" do
      expect(page).to have_text("Conferences")
      expect(page).to have_text(translated(participatory_space.title))
    end
  end

  scenario "shows breadcrumb with conference and component" do
    visit router.root_path

    within ".menu-bar" do
      expect(page).to have_text("Conferences")
      expect(page).to have_text(translated(participatory_space.title))
      expect(page).to have_text(translated(component.name))
    end
  end

  describe "with a program" do
    let(:meetings_component) { create(:meeting_component, :published, participatory_space:) }
    let!(:meeting) { create(:meeting, :published, latitude:, longitude:, component: meetings_component, start_time: 1.day.from_now) }

    let(:latitude) { 40.7504928941818 }
    let(:longitude) { -73.993466492276 }
    let(:geocoder_request_url) { "https://nominatim.openstreetmap.org/reverse?accept-language=en&addressdetails=1&format=json&lat=#{latitude}&lon=#{longitude}" }
    let(:geocoder_response) { File.read(Decidim::Dev.asset("geocoder_result_osm.json")) }

    before do
      stub_request(:get, geocoder_request_url).with(
        headers: {
          "Accept" => "*/*",
          "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
          "User-Agent" => "Ruby"
        }
      ).to_return(body: geocoder_response)
    end

    scenario "shows breadcrumb with conference and program" do
      visit decidim_conferences.conference_conference_program_path(participatory_space, meetings_component)

      within ".menu-bar" do
        expect(page).to have_text("Conferences")
        expect(page).to have_text(translated(participatory_space.title))
        expect(page).to have_text("Program")
      end
    end

    scenario "shows breadcrumb with conference, program, and meeting" do
      visit decidim_conferences.conference_conference_program_path(participatory_space, meetings_component)
      click_on decidim_sanitize_translated(meeting.title)

      within ".menu-bar" do
        expect(page).to have_text("Conferences")
        expect(page).to have_text(translated(participatory_space.title))
        expect(page).to have_text("Program")
        expect(page).to have_text(translated_attribute(meeting.title))
      end
    end
  end
end
