# frozen_string_literal: true

require "spec_helper"

describe "Explore meetings", :slow do
  include_context "with a component"
  let(:manifest_name) { "meetings" }

  let(:meetings_count) { 5 }
  let(:meetings_selector) { "[id^='meetings__meeting_']" }

  let!(:meetings) do
    create_list(:meeting, meetings_count, :not_official, :published, component:)
  end
  let(:taxonomy) { create(:taxonomy, :with_parent, skip_injection: true, organization:) }
  let(:taxonomy_filter) { create(:taxonomy_filter, root_taxonomy: taxonomy.parent) }
  let!(:taxonomy_filter_item) { create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: taxonomy) }
  let(:taxonomy_filter_ids) { [taxonomy_filter.id] }

  before do
    # Required for the link to be pointing to the correct URL with the server
    # port since the server port is not defined for the test environment.
    allow(ActionMailer::Base).to receive(:default_url_options).and_return(port: Capybara.server_port)
    component_settings = component["settings"]["global"].merge!(taxonomy_filters: taxonomy_filter_ids)
    component.update!(settings: component_settings)
  end

  describe "index" do
    it "shows all meetings for the given process" do
      visit_component
      expect(page).to have_selector(meetings_selector, count: meetings_count)

      meetings.each do |meeting|
        expect(page).to have_content(translated(meeting.title))
      end
    end

    context "when displaying calendar" do
      let(:component) { create(:meeting_component, participatory_space:) }
      let(:link) { Decidim::ShortLink.find_by(target_type: "Decidim::Component", target_id: component.id) }

      before do
        visit_component
      end

      context "when meetings mounted under participatory process" do
        let(:participatory_space) { create(:participatory_process, organization:) }

        it "properly saves the shortened link" do
          expect(link.mounted_engine_name).to eq("decidim_participatory_process_meetings")
        end
      end

      context "when meetings mounted under assemblies" do
        let(:participatory_space) { create(:assembly, organization:) }

        it "properly saves the shortened link" do
          expect(link.mounted_engine_name).to eq("decidim_assembly_meetings")
        end
      end
    end

    context "with default filter" do
      let!(:past_meeting) { create(:meeting, :published, start_time: 2.weeks.ago, component:) }
      let!(:upcoming_meeting) { create(:meeting, :published, :not_official, component:) }

      it "shows all the upcoming meetings" do
        visit_component
        within "#panel-dropdown-menu-date" do
          expect(find("input[value='upcoming']", visible: false).checked?).to be(true)
        end

        within "#meetings" do
          expect(page).to have_css(meetings_selector, count: 6)
        end

        expect(page).to have_content(translated(upcoming_meeting.title))
      end

      context "when maps are enabled" do
        let!(:meetings) { create_list(:meeting, 2, :not_official, :in_person, :published, component:) }
        let!(:hybrid_meetings) { create_list(:meeting, 2, :not_official, :hybrid, :published, component:) }
        let!(:online_meetings) { create_list(:meeting, 2, :not_official, :online, :published, component:) }
        let!(:upcoming_meeting) { create(:meeting, :not_official, :online, :published, component:) }

        # We are providing a list of coordinates to make sure the points are scattered all over the map
        # otherwise, there is a chance that markers can be clustered, which may result in a flaky spec.
        before do
          coordinates = [
            [-95.501705376541395, 95.10059236654689],
            [-95.501705376541395, -95.10059236654689],
            [95.10059236654689, -95.501705376541395],
            [95.10059236654689, 95.10059236654689],
            [142.15275006889419, -33.33377235135252],
            [33.33377235135252, -142.15275006889419],
            [-33.33377235135252, 142.15275006889419],
            [-142.15275006889419, 33.33377235135252],
            [-55.28745034772282, -35.587843900166945]
          ]
          Decidim::Meetings::Meeting.where(component:).geocoded.each_with_index do |meeting, index|
            meeting.update!(latitude: coordinates[index][0], longitude: coordinates[index][1]) if coordinates[index]
          end

          visit_component
        end

        it "shows markers for 'in person' selected meetings" do
          expect(page).to have_css(".leaflet-marker-icon", count: 4)
          within "#panel-dropdown-menu-type" do
            click_filter_item "In-person"
          end
          expect(page).to have_css(".leaflet-marker-icon", count: 2)

          expect_no_js_errors
        end

        it "shows markers for 'hybrid' selected meetings" do
          expect(page).to have_css(".leaflet-marker-icon", count: 4)
          within "#panel-dropdown-menu-type" do
            click_filter_item "Hybrid"
          end
          expect(page).to have_css(".leaflet-marker-icon", count: 2)

          expect_no_js_errors
        end

        it "hides markers when 'online' selected meetings" do
          expect(page).to have_css(".leaflet-marker-icon", count: 4)
          within "#panel-dropdown-menu-type" do
            click_filter_item "Online"
          end
          expect(page).to have_css(".leaflet-marker-icon", count: 0)

          expect_no_js_errors
        end
      end

      it "does not show past meetings" do
        visit_component
        within "#meetings" do
          expect(page).to have_no_content(translated(past_meeting.title))
        end
      end
    end

    context "when checking withdrawn meetings" do
      context "when there are no withdrawn meetings" do
        let!(:meeting) { create_list(:meeting, 3, :published, component:) }

        before do
          visit_component
          click_on "See all withdrawn meetings"
        end

        it "shows an empty page with a message" do
          expect(page).to have_content("No meetings match your search criteria or there is not any meeting scheduled.")
          within ".flash.info", match: :first do
            expect(page).to have_content("You are viewing the list of meetings withdrawn by their authors.")
          end
        end
      end

      context "when there are withdrawn meetings" do
        let!(:withdrawn_meetings) { create_list(:meeting, 3, :withdrawn, :published, component:) }

        before do
          visit_component
          click_on "See all withdrawn meetings"
        end

        it "shows all the withdrawn meetings" do
          expect(page).to have_css(".card__list-metadata div", text: "Withdrawn", count: 3)
          within ".flash.info", match: :first do
            expect(page).to have_content("You are viewing the list of meetings withdrawn by their authors.")
          end
        end
      end
    end

    context "with hidden meetings" do
      let(:meeting) { meetings.last }

      before do
        create(:moderation, :hidden, reportable: meeting)
      end

      it "does not list the hidden meetings" do
        visit_component

        expect(page).to have_selector(meetings_selector, count: meetings_count - 1)

        expect(page).to have_no_content(translated(meeting.title))
      end
    end

    context "when comments have been moderated" do
      let(:meeting) { create(:meeting, :published, component:) }
      let!(:comments) { create_list(:comment, 3, commentable: meeting) }
      let!(:moderation) { create(:moderation, reportable: comments.first, hidden_at: 1.day.ago) }

      it "displays unhidden comments count" do
        visit_component

        within("#meetings__meeting_#{meeting.id}") do
          expect(page).to have_css("[data-comments-count]", text: 2)
        end
      end
    end

    context "when filtering" do
      context "when filtering by text" do
        it "updates the current URL" do
          create(:meeting, :published, component:, title: { en: "Foobar meeting" })
          create(:meeting, :published, component:, title: { en: "Another meeting" })
          visit_component

          within "form.new_filter" do
            fill_in("filter[search_text_cont]", with: "foobar")
            within "div.filter-search" do
              click_on
            end
          end

          expect(page).to have_no_content("Another meeting")
          expect(page).to have_content("Foobar meeting")

          filter_params = CGI.parse(URI.parse(page.current_url).query)
          expect(filter_params["filter[search_text_cont]"]).to eq(["foobar"])
        end
      end

      context "when filtering by origin" do
        let!(:component) do
          create(:meeting_component,
                 :with_creation_enabled,
                 participatory_space: participatory_process)
        end

        let!(:official_meeting) { create(:meeting, :published, :official, component:, author: organization) }

        context "with 'official' origin" do
          it "lists the filtered meetings" do
            visit_component

            within "#panel-dropdown-menu-origin" do
              click_filter_item "Official"
            end

            expect(page).to have_css(meetings_selector, count: 1)

            within meetings_selector do
              expect(page).to have_content(translated(official_meeting.title))
            end
          end
        end

        context "with 'participants' origin" do
          it "lists the filtered meetings" do
            visit_component

            within "#panel-dropdown-menu-origin" do
              click_filter_item "Participants"
            end

            expect(page).to have_css(meetings_selector, count: meetings_count)
          end
        end
      end

      it "allows searching by text", :slow do
        visit_component
        within "form.new_filter" do
          fill_in("filter[search_text_cont]", with: translated(meetings.first.title))
          within "div.filter-search" do
            click_on
          end
        end

        expect(page).to have_css(meetings_selector, count: 1)
        expect(page).to have_content(translated(meetings.first.title))
      end

      context "when filtering by date" do
        let!(:past_meeting1) { create(:meeting, :published, component:, start_time: 1.week.ago) }
        let!(:past_meeting2) { create(:meeting, :published, component:, start_time: 3.months.ago) }
        let!(:past_meeting3) { create(:meeting, :published, component:, start_time: 2.days.ago) }
        let!(:upcoming_meeting1) { create(:meeting, :published, component:, start_time: 1.week.from_now) }
        let!(:upcoming_meeting2) { create(:meeting, :published, component:, start_time: 3.months.from_now) }
        let!(:upcoming_meeting3) { create(:meeting, :published, component:, start_time: 2.days.from_now) }

        it "lists filtered meetings" do
          visit_component

          within "#panel-dropdown-menu-date" do
            click_filter_item "Past"
          end

          expect(page).to have_css(meetings_selector, count: 3)
          expect(page).to have_content(translated(past_meeting1.title))
          expect(page).to have_no_content(translated(upcoming_meeting1.title))

          within "#panel-dropdown-menu-date" do
            click_filter_item "Upcoming"
          end

          expect(page).to have_content(translated(upcoming_meeting1.title))
          expect(page).to have_no_content(translated(past_meeting1.title))

          expect(page).to have_css(meetings_selector, count: 8)

          within "#panel-dropdown-menu-date" do
            click_filter_item "All"
          end

          expect(page).to have_css(meetings_selector, count: 8)
          expect(page).to have_content(translated(past_meeting1.title))
          expect(page).to have_content(translated(upcoming_meeting1.title))
        end

        context "when there are multiple past meetings" do
          it "orders them by start date" do
            visit_component
            within "#panel-dropdown-menu-date" do
              click_filter_item "Past"
            end

            expect(page).to have_content(translated(past_meeting1.title))

            result = page.find("#meetings .card__list-list").text
            expect(result.index(translated(past_meeting3.title))).to be < result.index(translated(past_meeting1.title))
            expect(result.index(translated(past_meeting1.title))).to be < result.index(translated(past_meeting2.title))
          end
        end

        context "when there are multiple upcoming meetings" do
          it "orders them by start date" do
            visit_component
            within "#panel-dropdown-menu-date" do
              click_filter_item "Upcoming"
            end

            expect(page).to have_content(translated(upcoming_meeting1.title))

            result = page.find("#meetings .card__list-list").text
            expect(result.index(translated(upcoming_meeting3.title))).to be < result.index(translated(upcoming_meeting1.title))
            expect(result.index(translated(upcoming_meeting1.title))).to be < result.index(translated(upcoming_meeting2.title))
          end
        end

        context "when there are multiple meetings" do
          it "orders them by start date" do
            page.visit "#{main_component_path(component)}?per_page=20"
            within "#panel-dropdown-menu-date" do
              click_filter_item "All"
            end

            expect(page).to have_content(translated(past_meeting1.title))

            result = page.find("#meetings .card__list-list").text
            expect(result.index(translated(past_meeting2.title))).to be < result.index(translated(past_meeting1.title))
            expect(result.index(translated(past_meeting1.title))).to be < result.index(translated(past_meeting3.title))
            expect(result.index(translated(past_meeting2.title))).to be < result.index(translated(upcoming_meeting1.title))
            expect(result.index(translated(upcoming_meeting3.title))).to be < result.index(translated(upcoming_meeting1.title))
            expect(result.index(translated(upcoming_meeting1.title))).to be < result.index(translated(upcoming_meeting2.title))
          end
        end
      end

      it "allows linking to the filtered view using a short link" do
        past_meeting = create(:meeting, :published, component:, start_time: 1.day.ago)
        visit_component

        within "#panel-dropdown-menu-date" do
          click_filter_item "Past"
        end

        expect(page).to have_css(meetings_selector, count: 1)
        expect(page).to have_content(translated(past_meeting.title))

        filter_params = CGI.parse(URI.parse(page.current_url).query)
        base_url = "http://#{organization.host}:#{Capybara.server_port}"

        click_on "Export calendar"
        expect(page).to have_css("#calendarShare", visible: :visible)
        within("#calendarShare") do
          expect(page).to have_content("Calendar URL")
        end
        short_url = nil
        within "#calendarShare" do
          input = find("input#urlCalendarUrl[readonly]")
          short_url = input.value
          expect(short_url).to match(%r{^#{base_url}/s/[a-zA-Z0-9]{10}$})
        end

        visit short_url
        expect(page).to have_css(meetings_selector, count: 1)
        expect(page).to have_content(translated(past_meeting.title))
        expect(page).to have_current_path(/^#{main_component_path(component)}/)

        current_params = CGI.parse(URI.parse(page.current_url).query)
        expect(current_params).to eq(filter_params)
      end

      it "allows filtering by taxonomies" do
        meeting = meetings.first
        meeting.taxonomies << taxonomy
        meeting.save

        visit_component

        within "#panel-dropdown-menu-taxonomy-#{taxonomy.parent.id}" do
          click_filter_item decidim_escape_translated(taxonomy.name)
        end

        expect(page).to have_css(meetings_selector, count: 1)
      end
    end

    context "when no upcoming meetings scheduled" do
      let!(:meetings) do
        create_list(:meeting, 2, :published, component:, start_time: 4.days.ago, end_time: 2.days.ago)
      end

      it "only shows the past meetings" do
        visit_component
        expect(page).to have_css(meetings_selector, count: 2)
      end

      it "shows the correct warning" do
        visit_component
        within ".flash" do
          expect(page).to have_content("no scheduled meetings")
        end
      end
    end

    context "when no meetings scheduled" do
      let!(:meetings) { [] }

      it "shows the correct warning" do
        visit_component
        within ".flash" do
          expect(page).to have_content("any meeting scheduled")
        end
      end
    end

    context "when paginating" do
      before do
        Decidim::Meetings::Meeting.destroy_all
      end

      let!(:collection) { create_list(:meeting, collection_size, :published, component:) }
      let!(:resource_selector) { meetings_selector }

      it_behaves_like "a paginated resource"
    end

    context "when there are only online meetings" do
      let!(:meetings) do
        create_list(:meeting, meetings_count, :online, :not_official, component:)
      end

      it "hides map" do
        visit_component

        expect(page).to have_no_css("div.map__help")
      end
    end
  end

  describe "show" do
    let(:meetings_count) { 1 }
    let(:meeting) { meetings.first }
    let(:date) { 10.days.from_now }

    before do
      meeting.update!(
        start_time: date.beginning_of_day,
        end_time: date.end_of_day
      )
      stub_geocoding_coordinates([meeting.latitude, meeting.longitude])
      visit resource_locator(meeting).path
    end

    it "shows all meeting info" do
      expect(page).to have_i18n_content(meeting.title)
      expect(page).to have_i18n_content(meeting.description, strip_tags: true)
      expect(page).to have_i18n_content(meeting.location, strip_tags: true)
      expect(page).to have_i18n_content(meeting.location_hints, strip_tags: true)
      expect(page).to have_content(meeting.address)
      expect(page).to have_content(meeting.reference)
      expect(page).to have_content(I18n.l(meeting.start_time, format: "%H:%M"))
      expect(page).to have_content(I18n.l(meeting.end_time, format: "%H:%M"))
      expect(page).to have_content("UTC")

      within ".meeting__calendar-day" do
        expect(page).to have_content(date.day)
      end
      within ".meeting__calendar-year" do
        expect(page).to have_content(/20\d\d/)
      end
    end

    context "when the organization has a different timezone" do
      before do
        organization.update!(time_zone: "Hawaii")

        visit resource_locator(meeting).path
      end

      it "shows the correct time zone" do
        expect(page).to have_content("HST")
      end
    end

    context "without taxonomies" do
      it "does not show any tag" do
        expect(page).to have_no_selector("[data-tags]")
      end
    end

    context "with a taxonomy" do
      let(:meeting) do
        meeting = meetings.first
        meeting.taxonomies << taxonomy
        meeting.save
        meeting
      end

      it "shows tags for taxonomy" do
        expect(page).to have_css("[data-tags]")
        within "[data-tags]" do
          expect(page).to have_content(decidim_escape_translated(taxonomy.name))
        end
      end

      it "links to the filter for this taxonomy" do
        within "[data-tags]" do
          click_on decidim_escape_translated(taxonomy.name)
        end

        expect(page).to have_checked_field(decidim_escape_translated(taxonomy.name))
      end
    end

    context "with linked proposals" do
      let(:proposal_component) do
        create(:component, manifest_name: :proposals, participatory_space: meeting.component.participatory_space)
      end
      let(:proposals) { create_list(:proposal, 3, component: proposal_component) }

      before do
        meeting.link_resources(proposals, "proposals_from_meeting")
      end

      it "shows related proposals" do
        visit_component
        click_on translated(meeting.title)
        proposals.each do |proposal|
          expect(page).to have_content(translated(proposal.title))
          expect(page).to have_content(proposal.creator_author.name)
          expect(page).to have_content(proposal.votes.size)
        end
      end
    end

    context "with linked results" do
      let(:accountability_component) do
        create(:component, manifest_name: :accountability, participatory_space: meeting.component.participatory_space)
      end
      let(:results) { create_list(:result, 3, component: accountability_component) }

      before do
        meeting.link_resources(results, "meetings_through_proposals")
      end

      it "shows related resources" do
        visit_component
        click_on translated(meeting.title)
        results.each do |result|
          expect(page).to have_i18n_content(result.title)
        end
      end
    end

    it_behaves_like "has attachments tabs" do
      let(:attached_to) { meeting }
    end

    shared_examples_for "a closing report page" do
      it "shows the closing report" do
        visit_component
        click_on translated(meeting.title)
        expect(page).to have_i18n_content(meeting.closing_report, strip_tags: true)

        within "[data-content]" do
          expect(page).to have_css(".meeting__aside-block", text: "Attendees count\n#{meeting.attendees_count}")
          expect(page).to have_css(".meeting__aside-block", text: "Attending organizations\n#{meeting.attending_organizations}")
        end
      end
    end

    context "when the meeting is closed and has audio and video urls" do
      let(:video_url) { "https://decidim.org" }
      let(:audio_url) { "https://example.com" }

      let!(:meeting) { create(:meeting, :published, :closed, contributions_count: 0, component:, video_url:, audio_url:) }

      it_behaves_like "a closing report page" do
        it "shows the video url" do
          expect(page).to have_content(video_url)
        end

        it "shows the audio url" do
          expect(page).to have_content(audio_url)
        end
      end
    end

    context "when the meeting is closed and had no contributions" do
      let!(:meeting) { create(:meeting, :published, :closed, contributions_count: 0, component:) }

      it_behaves_like "a closing report page"

      it "does not show contributions count" do
        within "[data-content]" do
          expect(page).to have_no_css(".meeting__aside-block", text: "Contributions count\n0")
        end
      end
    end

    context "when the meeting is closed and had contributions" do
      let!(:meeting) { create(:meeting, :published, :closed, contributions_count: 1, component:) }

      it_behaves_like "a closing report page"

      it "shows contributions count" do
        within "[data-content]" do
          expect(page).to have_css(".meeting__aside-block", text: "Contributions count\n1")
        end
      end
    end
  end
end
