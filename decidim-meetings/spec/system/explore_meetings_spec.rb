# frozen_string_literal: true

require "spec_helper"

describe "Explore meetings", type: :system do
  include_context "with a component"
  let(:manifest_name) { "meetings" }

  let(:meetings_count) { 5 }
  let!(:meetings) do
    create_list(:meeting, meetings_count, component: component)
  end

  describe "index" do
    it "shows all meetings for the given process" do
      visit_component
      expect(page).to have_selector("article.card", count: meetings_count)

      meetings.each do |meeting|
        expect(page).to have_content(translated(meeting.title))
      end
    end

    context "when filtering" do
      it "allows searching by text" do
        visit_component
        within ".filters" do
          fill_in :filter_search_text, with: translated(meetings.first.title)

          # The form should be auto-submitted when filter box is filled up, but
          # somehow it's not happening. So we workaround that be explicitly
          # clicking on "Search" until we find out why.
          find(".icon--magnifying-glass").click
        end

        expect(page).to have_css(".card--meeting", count: 1)
        expect(page).to have_content(translated(meetings.first.title))
      end

      it "allows filtering by date" do
        past_meeting = create(:meeting, component: component, start_time: 1.day.ago)
        visit_component

        within ".filters" do
          choose "Past"
        end

        expect(page).to have_css(".card--meeting", count: 1)
        expect(page).to have_content(translated(past_meeting.title))

        within ".filters" do
          choose "Upcoming"
        end

        expect(page).to have_css(".card--meeting", count: 5)
      end

      it "allows filtering by scope" do
        scope = create(:scope, organization: organization)
        meeting = meetings.first
        meeting.scope = scope
        meeting.save

        visit_component

        within ".filters" do
          scope_pick select_data_picker(:filter_scope_id, multiple: true, global_value: "global"), scope
        end

        expect(page).to have_css(".card--meeting", count: 1)
      end
    end

    context "when no upcoming meetings scheduled" do
      let!(:meetings) do
        create_list(:meeting, 2, component: component, start_time: Time.current - 4.days, end_time: Time.current - 2.days)
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

      let!(:collection) { create_list :meeting, collection_size, component: component }
      let!(:resource_selector) { ".card--meeting" }

      it_behaves_like "a paginated resource"
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
        expect(page).to have_select("filter_category_id", selected: translated(meeting.category.name))
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
          expect(select_data_picker(:filter_scope_id, multiple: true, global_value: "global")).to have_scope_picked(meeting.scope)
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
          expect(page).to have_content(proposal.title)
          expect(page).to have_content(proposal.author.name)
          expect(page).to have_content(proposal.votes.size)
        end
      end
    end

    context "with linked resources" do
      let(:dummy_component) do
        create(:component, manifest_name: :dummy, participatory_space: meeting.component.participatory_space)
      end
      let(:dummy_resources) { create_list(:dummy_resource, 3, component: dummy_component) }

      before do
        meeting.link_resources(dummy_resources, "meetings_through_dummy_resources")
      end

      it "shows related resources" do
        visit_component
        click_link translated(meeting.title)
        dummy_resources.each do |dummy_resource|
          expect(page).to have_i18n_content(dummy_resource.title)
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
          expect(page).to have_content("ATTENDEES COUNT #{meeting.attendees_count}")
          expect(page).to have_content("ATTENDING ORGANIZATIONS #{meeting.attending_organizations}")
        end
      end
    end

    context "when the meeting is closed and had no contributions" do
      let!(:meeting) { create(:meeting, :closed, contributions_count: 0, component: component) }

      it_behaves_like "a closing report page"

      it "does not show contributions count" do
        within ".definition-data" do
          expect(page).to have_no_content("CONTRIBUTIONS COUNT 0")
        end
      end
    end

    context "when the meeting is closed and had contributions" do
      let!(:meeting) { create(:meeting, :closed, contributions_count: 1, component: component) }

      it_behaves_like "a closing report page"

      it "shows contributions count" do
        within ".definition-data" do
          expect(page).to have_content("CONTRIBUTIONS COUNT 1")
        end
      end
    end
  end
end
