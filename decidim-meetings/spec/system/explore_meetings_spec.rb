# frozen_string_literal: true

require "spec_helper"

describe "Explore meetings", :slow, type: :system do
  include_context "with a component"
  let(:manifest_name) { "meetings" }

  let(:meetings_count) { 5 }
  let!(:meetings) do
    create_list(:meeting, meetings_count, :not_official, :published, component: component)
  end

  before do
    # Required for the link to be pointing to the correct URL with the server
    # port since the server port is not defined for the test environment.
    allow(ActionMailer::Base).to receive(:default_url_options).and_return(port: Capybara.server_port)
    component_scope = create :scope, parent: participatory_process.scope
    component_settings = component["settings"]["global"].merge!(scopes_enabled: true, scope_id: component_scope.id)
    component.update!(settings: component_settings)
  end

  describe "index" do
    it "shows all meetings for the given process" do
      visit_component
      expect(page).to have_selector(".card--meeting", count: meetings_count)

      meetings.each do |meeting|
        expect(page).to have_content(translated(meeting.title))
      end
    end

    context "with default filter" do
      let!(:past_meeting) { create(:meeting, :published, start_time: 2.weeks.ago, component: component) }
      let!(:upcoming_meeting) { create(:meeting, :published, :not_official, component: component) }

      it "shows all the upcoming meetings" do
        visit_component
        within ".with_any_date_collection_radio_buttons_filter" do
          expect(find("input[value='upcoming']").checked?).to be(true)
        end

        within "#meetings" do
          expect(page).to have_css(".card--meeting", count: 6)
        end

        expect(page).to have_css("#meetings-count", text: "6 MEETINGS")
        expect(page).to have_content(translated(upcoming_meeting.title))
      end

      it "doesn't show past meetings" do
        visit_component
        within "#meetings" do
          expect(page).not_to have_content(translated(past_meeting.title))
        end
      end
    end

    context "when checking withdrawn meetings" do
      context "when there are no withrawn meetings" do
        let!(:meeting) { create_list(:meeting, 3, :published, component: component) }

        before do
          visit_component
          click_link "See all withdrawn meetings"
        end

        it "shows an empty page with a message" do
          expect(page).to have_content("No meetings match your search criteria or there isn't any meeting scheduled.")
          within ".callout.warning", match: :first do
            expect(page).to have_content("You are viewing the list of meetings withdrawn by their authors.")
          end
        end
      end

      context "when there are withdrawn meetings" do
        let!(:withdrawn_meetings) { create_list(:meeting, 3, :withdrawn, :published, component: component) }

        before do
          visit_component
          click_link "See all withdrawn meetings"
        end

        it "shows all the withdrawn meetings" do
          expect(page).to have_css(".card--meeting.alert", count: 3)
          within ".callout.warning", match: :first do
            expect(page).to have_content("You are viewing the list of meetings withdrawn by their authors.")
          end
        end
      end
    end

    context "with hidden meetings" do
      let(:meeting) { meetings.last }

      before do
        create :moderation, :hidden, reportable: meeting
      end

      it "does not list the hidden meetings" do
        visit_component

        expect(page).to have_selector(".card.card--meeting", count: meetings_count - 1)

        expect(page).to have_no_content(translated(meeting.title))
      end
    end

    context "when comments have been moderated" do
      let(:meeting) { create(:meeting, :published, component: component) }
      let!(:comments) { create_list(:comment, 3, commentable: meeting) }
      let!(:moderation) { create :moderation, reportable: comments.first, hidden_at: 1.day.ago }

      it "displays unhidden comments count" do
        visit_component

        within("#meeting_#{meeting.id}") do
          within(".card__status") do
            within(".card-data__item:last-child") do
              expect(page).to have_content(2)
            end
          end
        end
      end
    end

    context "when filtering" do
      context "when filtering by origin" do
        let!(:component) do
          create(:meeting_component,
                 :with_creation_enabled,
                 participatory_space: participatory_process)
        end

        let!(:official_meeting) { create(:meeting, :published, :official, component: component, author: organization) }
        let!(:user_group_meeting) { create(:meeting, :published, :user_group_author, component: component) }

        context "with 'official' origin" do
          it "lists the filtered meetings" do
            visit_component

            within ".with_any_origin_check_boxes_tree_filter" do
              uncheck "All"
              check "Official"
            end

            expect(page).to have_no_content("6 MEETINGS")
            expect(page).to have_content("1 MEETING")
            expect(page).to have_css(".card--meeting", count: 1)

            within ".card--meeting" do
              expect(page).to have_content("Official meeting")
            end
          end
        end

        context "with 'groups' origin" do
          it "lists the filtered meetings" do
            visit_component

            within ".with_any_origin_check_boxes_tree_filter" do
              uncheck "All"
              check "Groups"
            end

            expect(page).to have_no_content("6 MEETINGS")
            expect(page).to have_content("1 MEETING")
            expect(page).to have_css(".card--meeting", count: 1)
            within ".card--meeting" do
              expect(page).to have_content(user_group_meeting.normalized_author.name)
            end
          end
        end

        context "with 'participants' origin" do
          it "lists the filtered meetings" do
            visit_component

            within ".with_any_origin_check_boxes_tree_filter" do
              uncheck "All"
              check "Participants"
            end

            expect(page).to have_no_content("6 MEETINGS")
            expect(page).to have_css(".card--meeting", count: meetings_count)
            expect(page).to have_content("#{meetings_count} MEETINGS")
          end
        end
      end

      it "allows searching by text", :slow do
        visit_component
        within ".filters" do
          # It seems that there's another field with the same name in another form on page.
          # Because of that we try to select the correct field to set the value and submit the right form
          find(:css, "#content form.new_filter [name='filter[search_text_cont]']").set(translated(meetings.first.title))

          # The form should be auto-submitted when filter box is filled up, but
          # somehow it's not happening. So we workaround that be explicitly
          # clicking on "Search" until we find out why.
          find("#content form.new_filter .icon--magnifying-glass").click
        end

        expect(page).to have_css("#meetings-count", text: "1 MEETING")
        expect(page).to have_css(".card--meeting", count: 1)
        expect(page).to have_content(translated(meetings.first.title))
      end

      it "allows filtering by date" do
        past_meeting = create(:meeting, :published, component: component, start_time: 1.day.ago)
        visit_component

        within ".with_any_date_collection_radio_buttons_filter" do
          choose "Past"
        end

        expect(page).to have_css(".card--meeting", count: 1)
        expect(page).to have_content(translated(past_meeting.title))

        within ".with_any_date_collection_radio_buttons_filter" do
          choose "Upcoming"
        end

        expect(page).to have_css(".card--meeting", count: 5)
      end

      it "allows linking to the filtered view using a short link" do
        past_meeting = create(:meeting, :published, component: component, start_time: 1.day.ago)
        visit_component

        within ".with_any_date_collection_radio_buttons_filter" do
          choose "Past"
        end

        expect(page).to have_css(".card--meeting", count: 1)
        expect(page).to have_content(translated(past_meeting.title))

        filter_params = CGI.parse(URI.parse(page.current_url).query)
        base_url = "http://#{organization.host}:#{Capybara.server_port}"

        click_button "Export calendar"
        expect(page).to have_content("Calendar URL:")
        expect(page).to have_css("#calendarShare", visible: :visible)
        short_url = nil
        within "#calendarShare" do
          input = find("input#urlCalendarUrl[readonly]")
          short_url = input.value
          expect(short_url).to match(%r{^#{base_url}/s/[a-zA-Z0-9]{10}$})
        end

        visit short_url
        expect(page).to have_css(".card--meeting", count: 1)
        expect(page).to have_content(translated(past_meeting.title))
        expect(page).to have_current_path(/^#{main_component_path(component)}/)

        current_params = CGI.parse(URI.parse(page.current_url).query)
        expect(current_params).to eq(filter_params)
      end

      it "allows filtering by scope" do
        scope = create(:scope, organization: organization)
        meeting = meetings.first
        meeting.scope = scope
        meeting.save

        visit_component

        within ".with_any_scope_check_boxes_tree_filter" do
          check "All"
          uncheck "All"
          check translated(scope.name)
        end

        expect(page).to have_css(".card--meeting", count: 1)
      end

      it "works with 'back to list' link" do
        scope = create(:scope, organization: organization)
        meeting = meetings.first
        meeting.scope = scope
        meeting.save

        visit_component

        within ".with_any_scope_check_boxes_tree_filter" do
          check "All"
          uncheck "All"
          check translated(scope.name)
        end

        expect(page).to have_css(".card--meeting", count: 1)

        find(".card--meeting .card__link").click
        click_link "Back to list"

        expect(page).to have_css(".card--meeting", count: 1)
      end
    end

    context "when no upcoming meetings scheduled" do
      let!(:meetings) do
        create_list(:meeting, 2, :published, component: component, start_time: 4.days.ago, end_time: 2.days.ago)
      end

      it "only shows the past meetings" do
        visit_component
        expect(page).to have_css(".card--meeting", count: 2)
      end

      it "shows the correct warning" do
        visit_component
        within ".callout" do
          expect(page).to have_content("no scheduled meetings")
        end
      end
    end

    context "when no meetings scheduled" do
      let!(:meetings) { [] }

      it "shows the correct warning" do
        visit_component
        within ".callout" do
          expect(page).to have_content("any meeting scheduled")
        end
      end
    end

    context "when paginating" do
      before do
        Decidim::Meetings::Meeting.destroy_all
      end

      let!(:collection) { create_list :meeting, collection_size, :published, component: component }
      let!(:resource_selector) { ".card--meeting" }

      it_behaves_like "a paginated resource"
    end

    context "when there are only online meetings" do
      let!(:meetings) do
        create_list(:meeting, meetings_count, :online, :not_official, component: component)
      end

      it "hides map" do
        visit_component

        expect(page).to have_no_css("div.map__help")
      end
    end
  end

  describe "show", :serves_map do
    let(:meetings_count) { 1 }
    let(:meeting) { meetings.first }
    let(:date) { 10.days.from_now }

    before do
      meeting.update!(
        start_time: date.beginning_of_day,
        end_time: date.end_of_day
      )

      visit resource_locator(meeting).path
    end

    it "shows all meeting info" do
      expect(page).to have_i18n_content(meeting.title)
      expect(page).to have_i18n_content(meeting.description)
      expect(page).to have_i18n_content(meeting.location)
      expect(page).to have_i18n_content(meeting.location_hints)
      expect(page).to have_content(meeting.address)
      expect(page).to have_content(meeting.reference)

      within ".section.view-side" do
        expect(page).to have_content(date.day)
        expect(page).to have_content("00:00 - 23:59")
      end
    end

    context "without category or scope" do
      it "does not show any tag" do
        expect(page).to have_no_selector("ul.tags.tags--meeting")
      end
    end

    context "with a category" do
      let(:meeting) do
        meeting = meetings.first
        meeting.category = create(:category, participatory_space: participatory_process)
        meeting.save
        meeting
      end

      it "shows tags for category" do
        expect(page).to have_selector("ul.tags.tags--meeting")
        within "ul.tags.tags--meeting" do
          expect(page).to have_content(translated(meeting.category.name))
        end
      end

      it "links to the filter for this category" do
        within "ul.tags.tags--meeting" do
          click_link translated(meeting.category.name)
        end

        expect(page).to have_checked_field(translated(meeting.category.name))
      end
    end

    context "with a scope" do
      let(:meeting) do
        meeting = meetings.first
        meeting.scope = create(:scope, organization: organization)
        meeting.save
        meeting
      end

      it "shows tags for scope" do
        expect(page).to have_selector("ul.tags.tags--meeting")
        within "ul.tags.tags--meeting" do
          expect(page).to have_content(translated(meeting.scope.name))
        end
      end

      it "links to the filter for this scope" do
        within "ul.tags.tags--meeting" do
          click_link translated(meeting.scope.name)
        end

        within ".filters" do
          expect(page).to have_checked_field(translated(meeting.scope.name))
        end
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
        click_link translated(meeting.title)
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
        click_link translated(meeting.title)
        results.each do |result|
          expect(page).to have_i18n_content(result.title)
        end
      end
    end

    it_behaves_like "has attachments" do
      let(:attached_to) { meeting }
    end

    shared_examples_for "a closing report page" do
      it "shows the closing report" do
        visit_component
        click_link translated(meeting.title)
        expect(page).to have_i18n_content(meeting.closing_report)

        within ".definition-data" do
          expect(page).to have_content("ATTENDEES COUNT\n#{meeting.attendees_count}")
          expect(page).to have_content("ATTENDING ORGANIZATIONS\n#{meeting.attending_organizations}")
        end
      end
    end

    context "when the meeting is closed and had no contributions" do
      let!(:meeting) { create(:meeting, :published, :closed, contributions_count: 0, component: component) }

      it_behaves_like "a closing report page"

      it "does not show contributions count" do
        within ".definition-data" do
          expect(page).to have_no_content("CONTRIBUTIONS COUNT\n0")
        end
      end
    end

    context "when the meeting is closed and had contributions" do
      let!(:meeting) { create(:meeting, :published, :closed, contributions_count: 1, component: component) }

      it_behaves_like "a closing report page"

      it "shows contributions count" do
        within ".definition-data" do
          expect(page).to have_content("CONTRIBUTIONS COUNT\n1")
        end
      end
    end
  end
end
