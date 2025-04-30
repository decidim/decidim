# frozen_string_literal: true

require "spec_helper"

describe "Meeting", download: true do
  include_context "with a component"
  let(:manifest_name) { "meetings" }

  let(:meeting) { create(:meeting, :published, :with_services, component:) }
  let!(:user) { create(:user, :confirmed, organization:) }

  def visit_meeting
    visit resource_locator(meeting).path
  end

  before do
    stub_geocoding_coordinates([meeting.latitude, meeting.longitude])
  end

  it "has a link to download the meeting in ICS format" do
    visit_meeting
    click_on "Add to calendar"

    expect(page).to have_link("Add to Outlook calendar")

    click_on("Add to Outlook calendar")

    expect(File.basename(download_path)).to include(".ics")
  end

  it "has a link to add to google calendar" do
    visit_meeting
    click_on "Add to calendar"

    expect(page).to have_link("Add to Google calendar", href: /calendar\.google\.com/)
  end

  context "when meeting has services" do
    it "they show it" do
      visit_meeting

      within "[data-content]" do
        expect(page).to have_css(".meeting__aside-block", count: meeting.services.size)

        services_titles = meeting.services.map { |service| service.title["en"] }
        services_present_in_pages = current_scope.all(".meeting__aside-block__title").map(&:text)
        expect(services_titles).to include(*services_present_in_pages)
      end
    end
  end

  context "when component is not commentable" do
    let!(:resources) { create_list(:meeting, 3, :published, :with_services, component:) }

    it_behaves_like "an uncommentable component"
  end

  context "when component has maps enabled" do
    let!(:component) do
      create(:component,
             manifest:,
             participatory_space:)
    end

    context "and meeting is online" do
      let(:meeting) { create(:meeting, :published, :with_services, :online, component:) }

      it "hides the map section" do
        visit_meeting

        expect(page).to have_no_css("div.meeting__calendar-container .static-map")
      end
    end

    context "and meeting is in_person" do
      let(:meeting) { create(:meeting, :published, :with_services, component:) }

      it "shows the map section" do
        visit_meeting

        expect(page).to have_css("div.meeting__calendar-container .static-map")
      end
    end

    context "and meeting has no address" do
      let(:meeting) { create(:meeting, :published, :with_services, component:, address: "", location: { "en" => "" }) }

      it "hides the map and displays pending address text" do
        visit_meeting

        expect(page).to have_no_css("div.meeting__calendar-container .static-map")
        expect(page).to have_content(I18n.t("show.pending_address", scope: "decidim.meetings.meetings"))
      end
    end

    context "and meeting is hybrid" do
      let(:meeting) { create(:meeting, :published, :with_services, :hybrid, component:) }

      it "shows the map section" do
        visit_meeting

        expect(page).to have_css("div.meeting__calendar-container .static-map")
      end
    end
  end

  context "when component has maps disabled" do
    let!(:component) do
      create(:component,
             manifest:,
             participatory_space:)
    end

    before do
      component.update!(settings: { maps_enabled: false })
    end

    context "and meeting is in_person" do
      let(:meeting) { create(:meeting, :published, :with_services, component:) }

      it "hides the map section but displays address" do
        visit_meeting

        expect(page).to have_no_css("div.meeting__calendar-container .static-map")
        expect(page).to have_css("div.meeting__calendar-container .address__container")
      end
    end

    context "and meeting is hybrid" do
      let(:meeting) { create(:meeting, :published, :with_services, :hybrid, component:) }

      it "hides the map section" do
        visit_meeting

        expect(page).to have_no_css("div.meeting__calendar-container .static-map")
      end
    end
  end

  context "when the meeting is the same as the current year" do
    let(:meeting) { create(:meeting, :published, component:, start_time: Time.current) }

    it "shows the year" do
      visit_meeting

      within ".meeting__calendar-container .meeting__calendar" do
        expect(page).to have_content(meeting.start_time.year)
      end
    end
  end

  context "when the meeting has no address and location" do
    let(:meeting) { create(:meeting, :published, component:, address: "", location: { "en" => "" }) }

    it "displays the pending address text" do
      visit_meeting

      expect(page).to have_content(I18n.t("show.pending_address", scope: "decidim.meetings.meetings"))
    end
  end

  context "when meeting has an address and location" do
    let(:meeting) { create(:meeting, :published, component:, address: "123 Main St", location: { "en" => "Central Park" }) }

    it "displays the location and address" do
      visit_meeting

      expect(page).to have_content("123 Main St")
      expect(page).to have_content("Central Park")
      expect(page).to have_no_content(I18n.t("show.pending_address", scope: "decidim.meetings.meetings"))
    end
  end

  context "when user is logged and session is about to timeout" do
    before do
      allow(Decidim.config).to receive(:expire_session_after).and_return(2.minutes)
      allow(Decidim.config).to receive(:session_timeout_interval).and_return(1.second)
      login_as user, scope: :user
    end

    context "when meeting is live" do
      let(:meeting) { create(:meeting, :published, component:, start_time: 1.minute.ago, end_time: 1.hour.from_now) }

      it "does not timeout user" do
        visit_meeting
        travel 1.minute
        expect(page).to have_no_content("If you continue being inactive", wait: 4)
        expect(page).to have_no_content("You were inactive for too long")
      end
    end

    context "when meeting is in future" do
      let(:meeting) { create(:meeting, :published, component:, start_time: 1.day.from_now, end_time: 1.day.from_now + 2.hours) }

      it "timeouts user normally" do
        visit_meeting
        travel 1.minute
        expect(page).to have_content("You were inactive for too long")
      end

      context "when comments are enabled" do
        let(:comment) { create(:comment, commentable: meeting) }

        before do
          component.settings[:comments_enabled] = true
        end

        it "fetching comments does not prevent timeout" do
          visit_meeting
          comment
          expect(page).to have_content(translated(comment.body), wait: 30)
          expect(page).to have_content("If you continue being inactive", wait: 30)
          expect(page).to have_content("You were inactive for too long", wait: 30)
        end
      end
    end
  end
end
