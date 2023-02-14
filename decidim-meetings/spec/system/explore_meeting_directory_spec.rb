# frozen_string_literal: true

require "spec_helper"

describe "Explore meeting directory", type: :system do
  let(:directory) { Decidim::Meetings::DirectoryEngine.routes.url_helpers.root_path }
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
    switch_to_host(organization.host)
    visit directory
  end

  describe "with default filter" do
    let!(:past_meeting) { create(:meeting, :published, start_time: 2.weeks.ago, component: components.first) }
    let!(:upcoming_meeting) { create(:meeting, :published, :not_official, component: components.first) }

    it "shows all the upcoming meetings" do
      visit directory

      within ".date_collection_radio_buttons_filter" do
        expect(find("input[value='upcoming']").checked?).to be(true)
      end

      within "#meetings" do
        expect(page).to have_css(".card--meeting", count: 7)
      end

      expect(page).to have_css("#meetings-count", text: "7 MEETINGS")
      expect(page).to have_content(translated(upcoming_meeting.title))
    end

    it "doesn't show past meetings" do
      within "#meetings" do
        expect(page).not_to have_content(translated(past_meeting.title))
      end
    end
  end

  describe "text filter" do
    it "updates the current URL" do
      create(:meeting, :published, component: components[0], title: { en: "Foobar meeting" })
      create(:meeting, :published, component: components[1], title: { en: "Another meeting" })
      visit directory

      within "form.new_filter" do
        fill_in("filter[search_text]", with: "foobar")
        click_button "Search"
      end

      within ".origin_check_boxes_tree_filter" do
        uncheck "Citizens"
      end

      expect(page).not_to have_content("Another meeting")
      expect(page).to have_content("Foobar meeting")

      filter_params = CGI.parse(URI.parse(page.current_url).query)
      expect(filter_params["filter[search_text]"]).to eq(["foobar"])
    end
  end

  describe "category filter" do
    context "with a category" do
      let!(:category1) do
        create(:category, participatory_space: participatory_process, name: { "en": "Category1" })
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

        within ".category_id_check_boxes_tree_filter" do
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

      within ".scope_id_check_boxes_tree_filter" do
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

        within ".origin_check_boxes_tree_filter" do
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

        within ".origin_check_boxes_tree_filter" do
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

    context "with 'citizens' origin" do
      it "lists the filtered meetings" do
        visit directory

        within ".origin_check_boxes_tree_filter" do
          uncheck "All"
          check "Citizens"
        end

        expect(page).to have_css(".card--meeting", count: 6)
        expect(page).to have_content("6 MEETINGS")
      end
    end
  end

  describe "type filter" do
    context "when there are only online meetings" do
      let!(:online_meeting1) { create(:meeting, :published, :online, component: components.last) }
      let!(:online_meeting2) { create(:meeting, :published, :online, component: components.last) }

      it "allows filtering by type 'online'" do
        within ".type_check_boxes_tree_filter" do
          uncheck "All"
          check "Online"
        end

        expect(page).to have_content(online_meeting1.title["en"])
        expect(page).to have_content(online_meeting2.title["en"])
        expect(page).to have_css("#meetings-count", text: "2 MEETINGS")
      end
    end

    context "when there are only in-person meetings" do
      let!(:in_person_meeting) { create(:meeting, :published, :in_person, component: components.last) }

      it "allows filtering by type 'in-person'" do
        within ".type_check_boxes_tree_filter" do
          uncheck "All"
          check "In-person"
        end

        expect(page).to have_content(in_person_meeting.title["en"])
        expect(page).to have_css("#meetings-count", text: "7 MEETINGS") # default meeting component it's with type "in-person"
      end
    end

    context "when there are hybrid meetings" do
      let!(:online_meeting) { create(:meeting, :published, :hybrid, component: components.last) }

      it "allows filtering by type 'both'" do
        within ".type_check_boxes_tree_filter" do
          uncheck "All"
          check "Hybrid"
        end

        expect(page).to have_css("#meetings-count", text: "1 MEETING")
      end
    end
  end

  describe "date filter" do
    let!(:past_meeting1) { create(:meeting, :published, component: components.last, start_time: 1.week.ago) }
    let!(:past_meeting2) { create(:meeting, :published, component: components.last, start_time: 3.months.ago) }
    let!(:past_meeting3) { create(:meeting, :published, component: components.last, start_time: 2.days.ago) }
    let!(:upcoming_meeting1) { create(:meeting, :published, component: components.last, start_time: 1.week.from_now) }
    let!(:upcoming_meeting2) { create(:meeting, :published, component: components.last, start_time: 3.months.from_now) }
    let!(:upcoming_meeting3) { create(:meeting, :published, component: components.last, start_time: 2.days.from_now) }

    context "with all meetings" do
      it "orders them by start date" do
        visit directory

        within ".date_collection_radio_buttons_filter" do
          choose "All"
        end

        expect(page).to have_css("#meetings-count", text: "12 MEETINGS")

        result = page.find("#meetings .card-grid").text
        expect(result.index(translated(past_meeting2.title))).to be < result.index(translated(past_meeting1.title))
        expect(result.index(translated(past_meeting1.title))).to be < result.index(translated(past_meeting3.title))
        expect(result.index(translated(past_meeting2.title))).to be < result.index(translated(upcoming_meeting1.title))
        expect(result.index(translated(upcoming_meeting3.title))).to be < result.index(translated(upcoming_meeting1.title))
        expect(result.index(translated(upcoming_meeting1.title))).to be < result.index(translated(upcoming_meeting2.title))
      end
    end

    context "with past meetings" do
      it "orders them by start date" do
        visit directory

        within ".date_collection_radio_buttons_filter" do
          choose "Past"
        end

        expect(page).to have_css("#meetings-count", text: "3 MEETINGS")

        result = page.find("#meetings .card-grid").text
        expect(result.index(translated(past_meeting3.title))).to be < result.index(translated(past_meeting1.title))
        expect(result.index(translated(past_meeting1.title))).to be < result.index(translated(past_meeting2.title))
      end
    end

    context "with upcoming meetings" do
      it "orders them by start date" do
        visit directory

        expect(page).to have_css("#meetings-count", text: "9 MEETINGS")

        result = page.find("#meetings .card-grid").text
        expect(result.index(translated(upcoming_meeting3.title))).to be < result.index(translated(upcoming_meeting1.title))
        expect(result.index(translated(upcoming_meeting1.title))).to be < result.index(translated(upcoming_meeting2.title))
      end
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
      within ".date_collection_radio_buttons_filter" do
        choose "Past"
      end

      expect(page).to have_no_css(".card--meeting")
      within(all(".filters__section")[7]) do
        uncheck "All"
        check "Assemblies"
      end

      within ".date_collection_radio_buttons_filter" do
        choose "Upcoming"
      end

      expect(page).to have_content(assembly_meeting.title["en"])
      expect(page).to have_css(".card--meeting", count: 1)
      expect(page).to have_css("#meetings-count", text: "1 MEETING")
    end
  end
end
