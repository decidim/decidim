# frozen_string_literal: true

require "spec_helper"

describe "Explore meeting directory", type: :system do
  let(:directory) do
    Decidim::Meetings::DirectoryEngine.routes.url_helpers.root_path
  end
  let(:organization) { create(:organization) }
  let(:participatory_process) { create :participatory_process, organization: organization }
  let(:components) do
    create_list(:meeting_component, 3, organization: organization)
  end
  let!(:meetings) do
    components.flat_map do |component|
      create_list(:meeting, 2, :published, :not_official, component: component)
    end
  end

  before do
    # Required for the link to be pointing to the correct URL with the server
    # port since the server port is not defined for the test environment.
    allow(ActionMailer::Base).to receive(:default_url_options).and_return(port: Capybara.server_port)
    switch_to_host(organization.host)
    visit directory
  end

  it "shows all the upcoming meetings" do
    within "#meetings" do
      expect(page).to have_css(".card--meeting", count: 6)
    end

    expect(page).to have_css("#meetings-count", text: "6 MEETINGS")
  end

  describe "category filter" do
    context "with a category" do
      let!(:category1) do
        create(:category, participatory_space: participatory_process, name: { en: "Category1" })
      end
      let!(:meeting) do
        meeting = meetings.first
        meeting.category = category1
        meeting.save
        meeting
      end

      it "shows tags for category" do
        visit directory

        expect(page).to have_selector("ul.tags.tags--meeting")
        within "ul.tags.tags--meeting" do
          expect(page).to have_content(translated(meeting.category.name))
        end
      end

      it "allows filtering by category" do
        visit directory

        within ".with_any_global_category_check_boxes_tree_filter" do
          check "All"
          check translated(participatory_process.title)
        end

        expect(page).to have_content(translated(participatory_process.title))
        expect(page).to have_content(translated(meeting.category.name))
      end
    end
  end

  context "with a scope" do
    let!(:scope) { create(:scope, organization: organization) }
    let!(:meeting) do
      meeting = meetings.first
      meeting.scope = scope
      meeting.save
      meeting
    end

    it "allows filtering by scope" do
      visit directory

      within ".with_any_scope_check_boxes_tree_filter" do
        check "All"
        check translated(meeting.scope.name)
      end

      expect(page).to have_content(translated(meeting.scope.name))
    end
  end

  describe "origin filter" do
    context "with 'official'" do
      let!(:official_meeting) { create(:meeting, :published, :official, component: components.first, author: organization) }

      it "lists the filtered meetings" do
        visit directory

        within ".with_any_origin_check_boxes_tree_filter" do
          uncheck "All"
          check "Official"
        end

        expect(page).to have_content("1 MEETING")
        expect(page).to have_css(".card--meeting", count: 1)

        within ".card--meeting" do
          expect(page).to have_content("Official meeting")
        end
      end
    end

    context "with 'groups' origin" do
      let!(:user_group_meeting) { create(:meeting, :published, :user_group_author, component: components.first) }

      it "lists the filtered meetings" do
        visit directory

        within ".with_any_origin_check_boxes_tree_filter" do
          uncheck "All"
          check "Groups"
        end

        expect(page).to have_content("1 MEETING")
        expect(page).to have_css(".card--meeting", count: 1)
        within ".card--meeting" do
          expect(page).to have_content(user_group_meeting.normalized_author.name)
        end
      end
    end

    context "with 'participants' origin" do
      it "lists the filtered meetings" do
        visit directory

        within ".with_any_origin_check_boxes_tree_filter" do
          uncheck "All"
          check "Participants"
        end

        expect(page).to have_css(".card--meeting", count: 6)
        expect(page).to have_content("6 MEETINGS")
      end
    end
  end

  describe "type filter" do
    context "when there are only online meetings" do
      let!(:online_meeting1) do
        create(:meeting, :published, :online, component: components.last)
      end
      let!(:online_meeting2) do
        create(:meeting, :published, :online, component: components.last)
      end

      it "allows filtering by type 'online'" do
        within ".with_any_type_check_boxes_tree_filter" do
          uncheck "All"
          check "Online"
        end

        expect(page).to have_content(online_meeting1.title["en"])
        expect(page).to have_content(online_meeting2.title["en"])
        expect(page).to have_css("#meetings-count", text: "2 MEETINGS")
      end

      it "allows linking to the filtered view using a short link" do
        within ".with_any_type_check_boxes_tree_filter" do
          uncheck "All"
          check "Online"
        end

        expect(page).to have_content(online_meeting1.title["en"])
        expect(page).to have_content(online_meeting2.title["en"])
        expect(page).to have_css("#meetings-count", text: "2 MEETINGS")

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
        expect(page).to have_content(online_meeting1.title["en"])
        expect(page).to have_content(online_meeting2.title["en"])
        expect(page).to have_css("#meetings-count", text: "2 MEETINGS")
        expect(page).to have_current_path(/^#{directory}/)

        current_params = CGI.parse(URI.parse(page.current_url).query)
        expect(current_params).to eq(filter_params)
      end
    end

    context "when there are only in-person meetings" do
      let!(:in_person_meeting) do
        create(:meeting, :published, :in_person, component: components.last)
      end

      it "allows filtering by type 'in-person'" do
        within ".with_any_type_check_boxes_tree_filter" do
          uncheck "All"
          check "In-person"
        end

        expect(page).to have_content(in_person_meeting.title["en"])
        expect(page).to have_css("#meetings-count", text: "7 MEETINGS") # default meeting component it's with type "in-person"
      end
    end

    context "when there are hybrid meetings" do
      let!(:online_meeting) do
        create(:meeting, :published, :hybrid, component: components.last)
      end

      it "allows filtering by type 'both'" do
        within ".with_any_type_check_boxes_tree_filter" do
          uncheck "All"
          check "Hybrid"
        end

        expect(page).to have_css("#meetings-count", text: "1 MEETING")
      end
    end
  end

  context "when there's a past meeting" do
    let!(:past_meeting) do
      create(:meeting, :published, component: components.last, start_time: 1.week.ago)
    end

    it "allows filtering by past events" do
      within ".with_any_date_check_boxes_tree_filter" do
        uncheck "All"
        check "Past"
      end

      expect(page).to have_content(past_meeting.title["en"])
      expect(page).to have_css("#meetings-count", text: "1 MEETING")
    end
  end

  context "with different participatory spaces" do
    let(:assembly) do
      create(:assembly, organization: organization)
    end
    let(:assembly_component) do
      create(:meeting_component, participatory_space: assembly, organization: organization)
    end
    let!(:assembly_meeting) do
      create(:meeting, :published, component: assembly_component)
    end

    before do
      visit directory
    end

    it "allows filtering by space" do
      expect(page).to have_content(assembly_meeting.title["en"])

      # Since in the first load all the meeting are present, we need can't rely on
      # have_content to wait for the card list to change. This is a hack to
      # reset the contents to no meetings at all, and then showing only the upcoming
      # assembly meetings.
      within ".with_any_date_check_boxes_tree_filter" do
        uncheck "All"
        check "Past"
      end

      expect(page).to have_no_css(".card--meeting")
      within(all(".filters__section")[7]) do
        uncheck "All"
        check "Assemblies"
      end

      within ".with_any_date_check_boxes_tree_filter" do
        check "Upcoming"
      end

      expect(page).to have_content(assembly_meeting.title["en"])
      expect(page).to have_css(".card--meeting", count: 1)
      expect(page).to have_css("#meetings-count", text: "1 MEETING")
    end
  end
end
