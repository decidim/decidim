# frozen_string_literal: true

require "spec_helper"

describe "Meeting", type: :system, download: true do
  include_context "with a component"
  let(:manifest_name) { "meetings" }

  let(:meeting) { create :meeting, :published, :with_services, component: component }
  let!(:user) { create :user, :confirmed, organization: organization }

  def visit_meeting
    visit resource_locator(meeting).path
  end

  it "has a link to download the meeting in ICS format" do
    visit_meeting
    click_button "Add to calendar"

    expect(page).to have_link("Add to Outlook calendar")

    click_link("Add to Outlook calendar")

    expect(File.basename(download_path)).to include(".ics")
  end

  it "has a link to add to google calendar" do
    visit_meeting
    click_button "Add to calendar"

    expect(page).to have_link("Add to Google calendar", href: /calendar\.google\.com/)
  end

  context "when meeting has services" do
    it "they show it" do
      visit_meeting

      within ".view-side .card--list" do
        expect(page).to have_selector(".card--list__item", count: meeting.services.size)

        services_titles = meeting.services.map { |service| service.title["en"] }
        services_present_in_pages = current_scope.all(".card--list__heading").map(&:text)
        expect(services_titles).to include(*services_present_in_pages)
      end
    end
  end

  context "when component is not commentable" do
    let!(:resources) { create_list(:meeting, 3, :published, :with_services, component: component) }

    it_behaves_like "an uncommentable component"
  end

  context "when component has maps enabled" do
    let!(:component) do
      create(:component,
             manifest: manifest,
             participatory_space: participatory_space)
    end

    context "and meeting is online" do
      let(:meeting) { create :meeting, :published, :with_services, :online, component: component }

      it "hides the map section" do
        visit_meeting

        expect(page).to have_no_css("div.address__map")
      end
    end

    context "and meeting is in_person" do
      let(:meeting) { create :meeting, :published, :with_services, component: component }

      it "shows the map section" do
        visit_meeting

        expect(page).to have_css("div.address__map")
      end
    end

    context "and meeting is hybrid" do
      let(:meeting) { create :meeting, :published, :with_services, :hybrid, component: component }

      it "shows the map section" do
        visit_meeting

        expect(page).to have_css("div.address__map")
      end
    end
  end

  context "when component has maps disabled" do
    let!(:component) do
      create(:component,
             manifest: manifest,
             participatory_space: participatory_space)
    end

    before do
      component.update!(settings: { maps_enabled: false })
    end

    context "and meeting is in_person" do
      let(:meeting) { create :meeting, :published, :with_services, component: component }

      it "hides the map section" do
        visit_meeting

        expect(page).to have_no_css("div.address__map")
      end
    end

    context "and meeting is hybrid" do
      let(:meeting) { create :meeting, :published, :with_services, :hybrid, component: component }

      it "hides the map section" do
        visit_meeting

        expect(page).to have_no_css("div.address__map")
      end
    end
  end

  context "when the meeting is the same as the current year" do
    let(:meeting) { create(:meeting, :published, component: component, start_time: Time.current) }

    it "doesn't show the year" do
      visit_meeting

      within ".extra__date-container" do
        expect(page).to have_no_content(meeting.start_time.year)
      end
    end
  end

  context "when the meeting is different from the current year" do
    let(:meeting) { create(:meeting, :published, component: component, start_time: 1.year.ago, end_time: 1.year.ago + 7.days) }

    it "shows the year" do
      visit_meeting

      within ".extra__date-container" do
        expect(page).to have_content(meeting.start_time.year)
      end
    end
  end

  context "when user is logged and session is about to timeout" do
    before do
      allow(Decidim.config).to receive(:expire_session_after).and_return(2.minutes)
      allow(Decidim.config).to receive(:session_timeout_interval).and_return(1.second)
      login_as user, scope: :user
    end

    context "when meeting is live" do
      let(:meeting) { create(:meeting, :published, component: component, start_time: 1.minute.ago, end_time: 1.hour.from_now) }

      it "does not timeout user" do
        visit_meeting
        travel 1.minute
        expect(page).not_to have_content("If you continue being inactive", wait: 4)
        expect(page).not_to have_content("You were inactive for too long")
      end
    end

    context "when meeting is in future" do
      let(:meeting) { create(:meeting, :published, component: component, start_time: 1.day.from_now, end_time: 1.day.from_now + 2.hours) }

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

        it "fetching comments doesnt prevent timeout" do
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
