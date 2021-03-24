# frozen_string_literal: true

require "spec_helper"
require "decidim/proposals/test/capybara_proposals_picker"

describe "Admin manages meetings", type: :system, serves_map: true, serves_geocoding_autocomplete: true do
  let(:manifest_name) { "meetings" }
  let!(:meeting) { create :meeting, scope: scope, services: [], component: current_component }
  let(:address) { "Some address" }
  let(:latitude) { 40.1234 }
  let(:longitude) { 2.1234 }
  let(:service_titles) { ["This is the first service", "This is the second service"] }

  include_context "when managing a component as an admin"

  include Decidim::SanitizeHelper

  before do
    stub_geocoding(address, [latitude, longitude])
  end

  describe "listing meetings" do
    it "lists the meetings by start date" do
      old_meeting = create :meeting, scope: scope, services: [], component: current_component, start_time: 2.years.ago
      visit current_path

      expect(page).to have_selector("tbody tr:first-child", text: Decidim::Meetings::MeetingPresenter.new(meeting).title)
      expect(page).to have_selector("tbody tr:last-child", text: Decidim::Meetings::MeetingPresenter.new(old_meeting).title)
    end
  end

  describe "admin form" do
    before { click_on "New meeting" }

    it_behaves_like "having a rich text editor", "new_meeting", "full"
  end

  describe "when rendering the text in the update page" do
    before do
      click_link "Edit"
    end

    it "shows help text" do
      expect(help_text_for("label[for*='meeting_address']")).to be_present
      expect(help_text_for("div[data-tabs-content*='meeting-location']")).to be_present
      expect(help_text_for("div[data-tabs-content*='meeting-location_hints']")).to be_present
    end

    context "when there are multiple locales" do
      it "shows the title correctly in all available locales" do
        within "#meeting-title-tabs" do
          click_link "English"
        end
        expect(page).to have_css("input", text: meeting.title[:en], visible: :visible)

        within "#meeting-title-tabs" do
          click_link "Català"
        end
        expect(page).to have_css("input", text: meeting.title[:ca], visible: :visible)

        within "#meeting-title-tabs" do
          click_link "Castellano"
        end
        expect(page).to have_css("input", text: meeting.title[:es], visible: :visible)
      end

      it "shows the description correctly in all available locales" do
        within "#meeting-description-tabs" do
          click_link "English"
        end
        expect(page).to have_css("input", text: meeting.description[:en], visible: :visible)

        within "#meeting-description-tabs" do
          click_link "Català"
        end
        expect(page).to have_css("input", text: meeting.description[:ca], visible: :visible)

        within "#meeting-description-tabs" do
          click_link "Castellano"
        end
        expect(page).to have_css("input", text: meeting.description[:es], visible: :visible)
      end
    end

    context "when there is only one locale" do
      let(:organization) { create :organization, available_locales: [:en] }
      let(:component) { create(:component, manifest_name: manifest_name, organization: organization) }
      let!(:meeting) do
        create(:meeting, scope: scope, services: [], component: component,
                         title: { en: "Title" }, description: { en: "Description" })
      end

      it "shows the title correctly" do
        expect(page).not_to have_css("#meeting-title-tabs")
        expect(page).to have_css("input", text: meeting.title[:en], visible: :visible)
      end

      it "shows the description correctly" do
        expect(page).not_to have_css("#meeting-description-tabs")
        expect(page).to have_css("input", text: meeting.description[:en], visible: :visible)
      end
    end
  end

  it "updates a meeting", :serves_geocoding_autocomplete do
    within find("tr", text: Decidim::Meetings::MeetingPresenter.new(meeting).title) do
      click_link "Edit"
    end

    within ".edit_meeting" do
      fill_in_i18n(
        :meeting_title,
        "#meeting-title-tabs",
        en: "My new title",
        es: "Mi nuevo título",
        ca: "El meu nou títol"
      )
      fill_in_geocoding :meeting_address, with: address

      find("*[type=submit]").click
    end

    expect(page).to have_admin_callout("successfully")

    within "table" do
      expect(page).to have_content("My new title")
    end
  end

  it "adds a few services to the meeting", :serves_geocoding_autocomplete do
    within find("tr", text: Decidim::Meetings::MeetingPresenter.new(meeting).title) do
      click_link "Edit"
    end

    within ".edit_meeting" do
      fill_in_geocoding :meeting_address, with: address
      fill_in_services

      expect(page).to have_selector(".meeting-service", count: 2)

      find("*[type=submit]").click
    end

    expect(page).to have_admin_callout("successfully")

    within find("tr", text: Decidim::Meetings::MeetingPresenter.new(meeting).title) do
      click_link "Edit"
    end

    expect(page).to have_selector("input[value='This is the first service']")
    expect(page).to have_selector("input[value='This is the second service']")
  end

  it "allows the user to preview the meeting" do
    within find("tr", text: Decidim::Meetings::MeetingPresenter.new(meeting).title) do
      klass = "action-icon--preview"
      href = resource_locator(meeting).path
      target = "blank"

      expect(page).to have_selector(
        :xpath,
        "//a[contains(@class,'#{klass}')][@href='#{href}'][@target='#{target}']"
      )
    end
  end

  it "creates a new meeting", :slow, :serves_geocoding_autocomplete do # rubocop:disable RSpec/ExampleLength
    find(".card-title a.button").click

    fill_in_i18n(
      :meeting_title,
      "#meeting-title-tabs",
      en: "My meeting",
      es: "Mi meeting",
      ca: "El meu meeting"
    )

    select "In person", from: :meeting_type_of_meeting

    fill_in_i18n(
      :meeting_location,
      "#meeting-location-tabs",
      en: "Location",
      es: "Location",
      ca: "Location"
    )
    fill_in_i18n(
      :meeting_location_hints,
      "#meeting-location_hints-tabs",
      en: "Location hints",
      es: "Location hints",
      ca: "Location hints"
    )
    fill_in_i18n_editor(
      :meeting_description,
      "#meeting-description-tabs",
      en: "A longer description",
      es: "Descripción más larga",
      ca: "Descripció més llarga"
    )

    fill_in_geocoding :meeting_address, with: address
    fill_in_services

    select "Registration disabled", from: :meeting_registration_type

    page.execute_script("$('#meeting_start_time').focus()")
    page.find(".datepicker-dropdown .day:not(.new)", text: "12").click
    page.find(".datepicker-dropdown .hour", text: "10:00").click
    page.find(".datepicker-dropdown .minute", text: "10:50").click

    page.execute_script("$('#meeting_end_time').focus()")
    page.find(".datepicker-dropdown .day:not(.new)", text: "12").click
    page.find(".datepicker-dropdown .hour", text: "12:00").click
    page.find(".datepicker-dropdown .minute", text: "12:50").click

    scope_pick select_data_picker(:meeting_decidim_scope_id), scope
    select translated(category.name), from: :meeting_decidim_category_id

    within ".new_meeting" do
      find("*[type=submit]").click
    end

    expect(page).to have_admin_callout("successfully")

    within "table" do
      expect(page).to have_content("My meeting")
    end
  end

  context "when using the front-end geocoder", :serves_geocoding_autocomplete do
    it_behaves_like(
      "a record with front-end geocoding address field",
      Decidim::Meetings::Meeting,
      within_selector: ".new_meeting",
      address_field: :meeting_address
    ) do
      let(:geocoded_address_value) { address }
      let(:geocoded_address_coordinates) { [latitude, longitude] }

      before do
        # Prepare the view for submission (other than the address field)
        find(".card-title a.button").click

        fill_in_i18n(
          :meeting_title,
          "#meeting-title-tabs",
          en: "My meeting",
          es: "Mi meeting",
          ca: "El meu meeting"
        )

        select "In person", from: :meeting_type_of_meeting

        fill_in_i18n(
          :meeting_location,
          "#meeting-location-tabs",
          en: "Location",
          es: "Location",
          ca: "Location"
        )
        fill_in_i18n(
          :meeting_location_hints,
          "#meeting-location_hints-tabs",
          en: "Location hints",
          es: "Location hints",
          ca: "Location hints"
        )
        fill_in_i18n_editor(
          :meeting_description,
          "#meeting-description-tabs",
          en: "A longer description",
          es: "Descripción más larga",
          ca: "Descripció més llarga"
        )

        select "Registration disabled", from: :meeting_registration_type

        page.execute_script("$('#meeting_start_time').focus()")
        page.find(".datepicker-dropdown .day:not(.new)", text: "12").click
        page.find(".datepicker-dropdown .hour", text: "10:00").click
        page.find(".datepicker-dropdown .minute", text: "10:50").click

        page.execute_script("$('#meeting_end_time').focus()")
        page.find(".datepicker-dropdown .day:not(.new)", text: "12").click
        page.find(".datepicker-dropdown .hour", text: "12:00").click
        page.find(".datepicker-dropdown .minute", text: "12:50").click
      end
    end
  end

  it "lets the user choose the meeting type" do
    find(".card-title a.button").click

    within ".new_meeting" do
      select "In person", from: :meeting_type_of_meeting
      expect(page).to have_field("Address")
      expect(page).to have_field(:meeting_location_en)
      expect(page).to have_no_field("Online meeting URL")

      select "Online", from: :meeting_type_of_meeting
      expect(page).to have_no_field("Address")
      expect(page).to have_no_field(:meeting_location_en)
      expect(page).to have_field("Online meeting URL")

      select "Both", from: :meeting_type_of_meeting
      expect(page).to have_field("Address")
      expect(page).to have_field(:meeting_location_en)
      expect(page).to have_field("Online meeting URL")
    end
  end

  it "lets the user choose the registration type" do
    find(".card-title a.button").click

    within ".new_meeting" do
      select "Registration disabled", from: :meeting_registration_type
      expect(page).to have_no_field("Registration URL")
      expect(page).to have_no_field("Available slots")

      select "On a different platform", from: :meeting_registration_type
      expect(page).to have_field("Registration URL")
      expect(page).to have_no_field("Available slots")

      select "On this platform", from: :meeting_registration_type
      expect(page).to have_field("Available slots")
      expect(page).to have_no_field("Registration URL")
    end
  end

  describe "duplicating a meeting" do
    it "creates a new meeting", :slow, :serves_geocoding_autocomplete do
      within find("tr", text: Decidim::Meetings::MeetingPresenter.new(meeting).title) do
        click_link "Duplicate"
      end

      fill_in_i18n(
        :meeting_title,
        "#meeting-title-tabs",
        en: "My duplicate meeting",
        es: "Mi meeting duplicado",
        ca: "El meu meeting duplicat"
      )
      fill_in_i18n(
        :meeting_location,
        "#meeting-location-tabs",
        en: "Location",
        es: "Location",
        ca: "Location"
      )
      fill_in_i18n(
        :meeting_location_hints,
        "#meeting-location_hints-tabs",
        en: "Location hints",
        es: "Location hints",
        ca: "Location hints"
      )
      fill_in_i18n_editor(
        :meeting_description,
        "#meeting-description-tabs",
        en: "A longer description",
        es: "Descripción más larga",
        ca: "Descripció més llarga"
      )

      fill_in_geocoding :meeting_address, with: address

      page.execute_script("$('#meeting_start_time').focus()")
      page.find(".datepicker-dropdown .day:not(.new)", text: "12").click
      page.find(".datepicker-dropdown .hour", text: "10:00").click
      page.find(".datepicker-dropdown .minute", text: "10:50").click

      page.execute_script("$('#meeting_end_time').focus()")
      page.find(".datepicker-dropdown .day:not(.new)", text: "12").click
      page.find(".datepicker-dropdown .hour", text: "12:00").click
      page.find(".datepicker-dropdown .minute", text: "12:50").click

      within ".copy_meetings" do
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      within "table" do
        expect(page).to have_content("My duplicate meeting")
      end
    end
  end

  describe "deleting a meeting" do
    let!(:meeting2) { create(:meeting, component: current_component) }

    before do
      visit current_path
    end

    it "deletes a meeting" do
      within find("tr", text: Decidim::Meetings::MeetingPresenter.new(meeting2).title) do
        accept_confirm { click_link "Delete" }
      end

      expect(page).to have_admin_callout("successfully")

      within "table" do
        expect(page).to have_no_content(Decidim::Meetings::MeetingPresenter.new(meeting2).title)
      end
    end
  end

  context "when geocoding is disabled", :configures_map do
    before do
      Decidim.maps = {
        provider: :test,
        geocoding: false,
        autocomplete: false
      }
      Decidim::Map.reset_utility_configuration!
    end

    it "updates a meeting" do
      within find("tr", text: Decidim::Meetings::MeetingPresenter.new(meeting).title) do
        click_link "Edit"
      end

      within ".edit_meeting" do
        fill_in_i18n(
          :meeting_title,
          "#meeting-title-tabs",
          en: "My new title",
          es: "Mi nuevo título",
          ca: "El meu nou títol"
        )
        fill_in :meeting_address, with: address
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      within "table" do
        expect(page).to have_content("My new title")
      end
    end

    it "creates a new meeting", :slow do
      find(".card-title a.button").click

      fill_in_i18n(
        :meeting_title,
        "#meeting-title-tabs",
        en: "My meeting",
        es: "Mi meeting",
        ca: "El meu meeting"
      )

      select "In person", from: :meeting_type_of_meeting

      fill_in_i18n(
        :meeting_location,
        "#meeting-location-tabs",
        en: "Location",
        es: "Location",
        ca: "Location"
      )
      fill_in_i18n(
        :meeting_location_hints,
        "#meeting-location_hints-tabs",
        en: "Location hints",
        es: "Location hints",
        ca: "Location hints"
      )
      fill_in_i18n_editor(
        :meeting_description,
        "#meeting-description-tabs",
        en: "A longer description",
        es: "Descripción más larga",
        ca: "Descripció més llarga"
      )

      fill_in :meeting_address, with: address
      select "Registration disabled", from: :meeting_registration_type

      page.execute_script("$('#meeting_start_time').focus()")
      page.find(".datepicker-dropdown .day:not(.new)", text: "12").click
      page.find(".datepicker-dropdown .hour", text: "10:00").click
      page.find(".datepicker-dropdown .minute", text: "10:50").click

      page.execute_script("$('#meeting_end_time').focus()")
      page.find(".datepicker-dropdown .day:not(.new)", text: "12").click
      page.find(".datepicker-dropdown .hour", text: "12:00").click
      page.find(".datepicker-dropdown .minute", text: "12:50").click

      scope_pick select_data_picker(:meeting_decidim_scope_id), scope
      select translated(category.name), from: :meeting_decidim_category_id

      within ".new_meeting" do
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      within "table" do
        expect(page).to have_content("My meeting")
      end
    end
  end

  describe "closing a meeting" do
    let(:proposal_component) do
      create(:component, manifest_name: :proposals, participatory_space: meeting.component.participatory_space)
    end
    let!(:proposals) { create_list(:proposal, 3, component: proposal_component, skip_injection: true) }

    it "closes a meeting with a report" do
      within find("tr", text: Decidim::Meetings::MeetingPresenter.new(meeting).title) do
        page.click_link "Close"
      end

      within ".edit_close_meeting" do
        fill_in_i18n_editor(
          :close_meeting_closing_report,
          "#close_meeting-closing_report-tabs",
          en: "The meeting was great!",
          es: "El encuentro fue genial",
          ca: "La trobada va ser genial"
        )
        fill_in :close_meeting_attendees_count, with: 12
        fill_in :close_meeting_contributions_count, with: 44
        fill_in :close_meeting_attending_organizations, with: "Neighbours Association, Group of People Complaining About Something and Other People"
        proposals_pick(select_data_picker(:close_meeting_proposals, multiple: true), proposals.first(2))
        click_button "Close"
      end

      expect(page).to have_admin_callout("Meeting successfully closed")

      within find("tr", text: Decidim::Meetings::MeetingPresenter.new(meeting).title) do
        expect(page).to have_content("Yes")
      end
    end

    context "when a meeting has alredy been closed" do
      let!(:meeting) { create(:meeting, :closed, component: current_component) }

      it "can update the information" do
        within find("tr", text: Decidim::Meetings::MeetingPresenter.new(meeting).title) do
          page.click_link "Close"
        end

        within ".edit_close_meeting" do
          fill_in :close_meeting_attendees_count, with: 22
          click_button "Close"
        end

        expect(page).to have_admin_callout("Meeting successfully closed")
      end
    end
  end

  private

  def fill_in_services
    2.times { click_button "Add service" }

    page.all(".meeting-service").each_with_index do |meeting_service, index|
      within meeting_service do
        fill_in current_scope.find("[id$=title_en]", visible: :visible)["id"], with: service_titles[index]
      end
    end
  end

  def help_text_for(css)
    page.find_all(css).first.sibling(".help-text")
  end
end
