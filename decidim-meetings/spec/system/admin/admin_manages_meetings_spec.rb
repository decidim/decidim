# frozen_string_literal: true

require "spec_helper"
require "decidim/dev/test/rspec_support/tom_select"

describe "Admin manages meetings" do
  let(:manifest_name) { "meetings" }
  let!(:meeting) { create(:meeting, :published, services: [], component: current_component, start_time: base_date + 1.day, end_time: base_date + 26.hours) }
  let(:address) { "Some address" }
  let(:latitude) { 40.1234 }
  let(:longitude) { 2.1234 }
  let(:service_titles) { ["This is the first service", "This is the second service"] }
  let(:base_date) { Time.zone.now.change(usec: 0) }
  let(:meeting_start_date) { base_date.strftime("%d/%m/%Y") }
  let(:meeting_start_time) { base_date.utc.strftime("%H:%M") }
  let(:meeting_end_date) { ((base_date + 2.days) + 1.month).strftime("%d/%m/%Y") }
  let(:meeting_end_time) { (base_date + 4.hours).strftime("%H:%M") }
  let(:attributes) { attributes_for(:meeting, component: current_component, skip_injection: true) }
  let(:root_taxonomy) { create(:taxonomy, organization:) }
  let!(:taxonomy) { create(:taxonomy, parent: root_taxonomy, organization:) }
  let(:taxonomy_filter) { create(:taxonomy_filter, root_taxonomy:) }
  let!(:taxonomy_filter_item) { create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: taxonomy) }
  let(:taxonomy_filter_ids) { [taxonomy_filter.id] }
  let!(:follow) { create(:follow, followable: meeting, user:) }

  include_context "when managing a component as an admin" do
    let(:participatory_process) { create(:participatory_process, :published, :with_steps, organization:) }
    let!(:component) { create(:component, :published, manifest:, participatory_space:) }
  end

  before do
    stub_geocoding(address, [latitude, longitude])
    component.update!(settings: { taxonomy_filters: taxonomy_filter_ids })
  end

  describe "listing meetings" do
    it "lists the meetings by start date" do
      old_meeting = create(:meeting, services: [], component: current_component, start_time: 2.years.ago)
      visit current_path

      expect(page).to have_css("tbody tr:first-child", text: Decidim::Meetings::MeetingPresenter.new(meeting).title)
      expect(page).to have_css("tbody tr:last-child", text: Decidim::Meetings::MeetingPresenter.new(old_meeting).title)
    end

    it "allows to publish/unpublish meetings" do
      visit current_path

      within "tr", text: Decidim::Meetings::MeetingPresenter.new(meeting).title do
        find("button[data-component='dropdown']").click
        accept_confirm { click_on "Unpublish" }
      end

      expect(page).to have_admin_callout("successfully")

      within "tr", text: Decidim::Meetings::MeetingPresenter.new(meeting).title do
        find("button[data-component='dropdown']").click
        expect(page).to have_content("Publish")
      end

      within "tr", text: Decidim::Meetings::MeetingPresenter.new(meeting).title do
        click_on "Publish"
      end

      expect(page).to have_admin_callout("successfully")

      within "tr", text: Decidim::Meetings::MeetingPresenter.new(meeting).title do
        find("button[data-component='dropdown']").click
        expect(page).to have_content("Unpublish")
      end

      visit decidim.last_activities_path
      expect(page).to have_content("New meeting: #{decidim_sanitize_translated(meeting.title)}")

      within "#filters" do
        find("a", class: "filter", text: "Meeting", match: :first).click
      end
      expect(page).to have_content("New meeting: #{decidim_sanitize_translated(meeting.title)}")
    end

    context "with enriched content" do
      before do
        meeting.update!(title: { en: "Meeting <strong>title</strong>" })
        visit current_path
      end

      it "displays the correct title" do
        expect(page.html).to include("Meeting &lt;strong&gt;title&lt;/strong&gt;")
      end
    end
  end

  describe "admin form" do
    before { click_on "New meeting" }

    it_behaves_like "having a rich text editor", "new_meeting", "full"
  end

  describe "when rendering the text in the update page" do
    before do
      within "tr", text: Decidim::Meetings::MeetingPresenter.new(meeting).title do
        find("button[data-component='dropdown']").click
        click_on "Edit"
      end
    end

    it_behaves_like "having a rich text editor for field", ".tabs-content[data-tabs-content='meeting-description-tabs']", "full"

    it "shows help text" do
      expect(page).to have_content("used by Geocoder to find the location")
      expect(page).to have_content("message directed to the users implying the spot to meet at")
      expect(page).to have_content("the floor of the building if it is an in-person meeting")
    end

    context "when there are multiple locales" do
      it "shows the title correctly in all available locales" do
        within "#meeting-title-tabs" do
          click_on "English"
        end
        expect(page).to have_field(text: meeting.title[:en], visible: :visible)

        within "#meeting-title-tabs" do
          click_on "Català"
        end
        expect(page).to have_field(text: meeting.title[:ca], visible: :visible)

        within "#meeting-title-tabs" do
          click_on "Castellano"
        end
        expect(page).to have_field(text: meeting.title[:es], visible: :visible)
      end

      it "shows the description correctly in all available locales" do
        within "#meeting-description-tabs" do
          click_on "English"
        end
        expect(page).to have_field(text: meeting.description[:en], visible: :visible)

        within "#meeting-description-tabs" do
          click_on "Català"
        end
        expect(page).to have_field(text: meeting.description[:ca], visible: :visible)

        within "#meeting-description-tabs" do
          click_on "Castellano"
        end
        expect(page).to have_field(text: meeting.description[:es], visible: :visible)
      end
    end

    context "when there is only one locale" do
      let(:organization) { create(:organization, available_locales: [:en]) }
      let(:component) { create(:component, manifest_name:, organization:) }
      let!(:meeting) do
        create(:meeting, services: [], component:,
                         title: { en: "Title for the meeting" }, description: { en: "Description" })
      end

      it "shows the title correctly" do
        expect(page).to have_no_css("#meeting-title-tabs")
        expect(page).to have_field(text: meeting.title[:en], visible: :visible)
      end

      it "shows the description correctly" do
        expect(page).to have_no_css("#meeting-description-tabs")
        expect(page).to have_field(text: meeting.description[:en], visible: :visible)
      end
    end
  end

  it_behaves_like "having a rich text editor for field", ".tabs-content[data-tabs-content='meeting-description-tabs']", "full" do
    before do
      within "tr", text: Decidim::Meetings::MeetingPresenter.new(meeting).title do
        find("button[data-component='dropdown']").click
        click_on "Edit"
      end
    end
  end

  it "updates a meeting" do
    within "tr", text: Decidim::Meetings::MeetingPresenter.new(meeting).title do
      find("button[data-component='dropdown']").click
      click_on "Edit"
    end

    within ".edit_meeting" do
      fill_in_i18n(:meeting_title, "#meeting-title-tabs", **attributes[:title].except("machine_translations"))

      fill_in_i18n(:meeting_location, "#meeting-location-tabs", **attributes[:location].except("machine_translations"))
      fill_in_i18n(:meeting_location_hints, "#meeting-location_hints-tabs", **attributes[:location_hints].except("machine_translations"))
      fill_in_i18n_editor(:meeting_description, "#meeting-description-tabs", **attributes[:description].except("machine_translations"))

      fill_in_geocoding :meeting_address, with: address

      perform_enqueued_jobs do
        find("*[type=submit]").click
      end
    end

    expect(page).to have_admin_callout("successfully")

    within "table" do
      expect(page).to have_content(translated(attributes[:title]))
    end

    email = last_email
    sleep 1
    expect(email.subject).to include("updated")
    expect(email.body.encoded).to include(%(The "#{decidim_sanitize_translated(attributes[:title])}" meeting has been updated with changes to the address and the location))
    page.visit decidim.notifications_path
    expect(page).to have_content("The #{decidim_sanitize_translated(attributes[:title])} meeting has been updated with changes to the address and the location")

    visit decidim_admin.root_path
    expect(page).to have_content("updated the #{decidim_sanitize_translated(attributes[:title])} meeting on the")
  end

  it "sets registration enabled to true when registration type is on this platform" do
    within "tr", text: Decidim::Meetings::MeetingPresenter.new(meeting).title do
      find("button[data-component='dropdown']").click
      click_on "Edit"
    end

    within ".edit_meeting" do
      select "On this platform", from: :meeting_registration_type

      find("*[type=submit]").click
    end

    expect(page).to have_admin_callout("successfully")
    expect(meeting.reload.registrations_enabled).to be true
  end

  it "sets registration enabled to false when registration type is not on this platform" do
    within "tr", text: Decidim::Meetings::MeetingPresenter.new(meeting).title do
      find("button[data-component='dropdown']").click
      click_on "Edit"
    end

    within ".edit_meeting" do
      select "Registration disabled", from: :meeting_registration_type

      find("*[type=submit]").click
    end

    expect(page).to have_admin_callout("successfully")
    expect(meeting.reload.registrations_enabled).to be false
  end

  it "adds a few services to the meeting" do
    within "tr", text: Decidim::Meetings::MeetingPresenter.new(meeting).title do
      find("button[data-component='dropdown']").click
      click_on "Edit"
    end

    within ".edit_meeting" do
      fill_in_geocoding :meeting_address, with: address
      fill_in_services

      expect(page).to have_css(".meeting-service", count: 2)

      find("*[type=submit]").click
    end

    expect(page).to have_admin_callout("successfully")

    within "tr", text: Decidim::Meetings::MeetingPresenter.new(meeting).title do
      find("button[data-component='dropdown']").click
      click_on "Edit"
    end

    expect(page).to have_css("input[value='This is the first service']")
    expect(page).to have_css("input[value='This is the second service']")
  end

  describe "previewing" do
    it "allows the user to preview a published meeting" do
      within "tr", text: Decidim::Meetings::MeetingPresenter.new(meeting).title do
        find("button[data-component='dropdown']").click
        preview_window = window_opened_by { click_on "Preview" }

        within_window preview_window do
          expect(page).to have_current_path(resource_locator(meeting).path)
        end
      end
    end

    describe "with an unpublished meeting" do
      let!(:unpublished_meeting) { create(:meeting, services: [], component: current_component) }

      it "allows the user to preview it" do
        visit current_path

        within "tr", text: Decidim::Meetings::MeetingPresenter.new(unpublished_meeting).title do
          find("button[data-component='dropdown']").click
          preview_window = window_opened_by { click_on "Preview" }

          within_window preview_window do
            expect(page).to have_current_path(resource_locator(unpublished_meeting).path)
          end
        end
      end
    end
  end

  it "creates a new meeting" do
    click_on "New meeting"

    fill_in_i18n(:meeting_title, "#meeting-title-tabs", **attributes[:title].except("machine_translations"))

    select "In person", from: :meeting_type_of_meeting

    fill_in_i18n(:meeting_location, "#meeting-location-tabs", **attributes[:location].except("machine_translations"))
    fill_in_i18n(:meeting_location_hints, "#meeting-location_hints-tabs", **attributes[:location_hints].except("machine_translations"))
    fill_in_i18n_editor(:meeting_description, "#meeting-description-tabs", **attributes[:description].except("machine_translations"))

    fill_in_geocoding :meeting_address, with: address
    fill_in_services

    select "Registration disabled", from: :meeting_registration_type

    fill_in_datepicker :meeting_start_time_date, with: meeting_start_date
    fill_in_timepicker :meeting_start_time_time, with: meeting_start_time
    fill_in_datepicker :meeting_end_time_date, with: meeting_end_date
    fill_in_timepicker :meeting_end_time_time, with: meeting_end_time

    expect(page).to have_content("Send a reminder for this meeting")
    expect(page).to have_content("Scheduled reminder email")
    expect(page).to have_content("Reminder email content")

    fill_in :meeting_send_reminders_before_hours, with: 24
    fill_in_i18n(
      :meeting_reminder_message_custom_content,
      "#meeting-reminder_message_custom_content-tabs",
      en: "Custom message for the {{meeting_title}} meeting",
      es: "Custom message for the {{meeting_title}} meeting",
      ca: "Custom message for the {{meeting_title}} meeting"
    )

    select decidim_sanitize_translated(taxonomy.name), from: "taxonomies-#{taxonomy_filter.id}"

    within ".new_meeting" do
      find("*[type=submit]").click
    end

    expect(page).to have_admin_callout("successfully")

    within "table" do
      expect(page).to have_content(translated(attributes[:title]))
      expect(page).to have_content(translated(taxonomy.name))
    end

    visit decidim_admin.root_path
    expect(page).to have_content("created the #{translated(attributes[:title])} meeting on the")
  end

  context "when the venue has not been decided yet" do
    it "creates a new meeting without an address" do
      click_on "New meeting"

      fill_in_i18n(:meeting_title, "#meeting-title-tabs", **attributes[:title].except("machine_translations"))
      fill_in_i18n_editor(:meeting_description, "#meeting-description-tabs", **attributes[:description].except("machine_translations"))
      select "In person", from: :meeting_type_of_meeting
      select "Registration disabled", from: :meeting_registration_type
      fill_in_datepicker :meeting_start_time_date, with: meeting_start_date
      fill_in_timepicker :meeting_start_time_time, with: meeting_start_time
      fill_in_datepicker :meeting_end_time_date, with: meeting_end_date
      fill_in_timepicker :meeting_end_time_time, with: meeting_end_time

      within ".new_meeting" do
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      new_meeting = Decidim::Meetings::Meeting.last
      puts "Meeting location: #{new_meeting.location}"
      expect(new_meeting.location.values).to all(be_blank)
      expect(new_meeting.address).to be_empty
    end
  end

  context "when no taxonomy filter is selected" do
    let(:taxonomy_filter_ids) { [] }

    it "creates a meeting without taxonomies" do
      click_on "New meeting"

      fill_in_i18n(:meeting_title, "#meeting-title-tabs", **attributes[:title].except("machine_translations"))

      select "In person", from: :meeting_type_of_meeting

      fill_in_i18n(:meeting_location, "#meeting-location-tabs", **attributes[:location].except("machine_translations"))
      fill_in_i18n(:meeting_location_hints, "#meeting-location_hints-tabs", **attributes[:location_hints].except("machine_translations"))
      fill_in_i18n_editor(:meeting_description, "#meeting-description-tabs", **attributes[:description].except("machine_translations"))

      fill_in_geocoding :meeting_address, with: address
      fill_in_services

      select "Registration disabled", from: :meeting_registration_type

      fill_in_datepicker :meeting_start_time_date, with: meeting_start_date
      fill_in_timepicker :meeting_start_time_time, with: meeting_start_time
      fill_in_datepicker :meeting_end_time_date, with: meeting_end_date
      fill_in_timepicker :meeting_end_time_time, with: meeting_end_time

      expect(page).to have_no_content(decidim_sanitize_translated(root_taxonomy.name))

      within ".new_meeting" do
        find("*[type=submit]").click
      end

      expect(page).to have_content("successfully")

      within "table" do
        expect(page).to have_content(translated(attributes[:title]))
        expect(page).to have_no_content(translated(taxonomy.name))
      end
    end
  end

  context "when using the front-end geocoder" do
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
        click_on "New meeting"

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

        fill_in_datepicker :meeting_start_time_date, with: meeting_start_date
        fill_in_timepicker :meeting_start_time_time, with: meeting_start_time
        fill_in_datepicker :meeting_end_time_date, with: meeting_end_date
        fill_in_timepicker :meeting_end_time_time, with: meeting_end_time
      end
    end
  end

  it "lets the user choose the meeting type" do
    click_on "New meeting"

    within ".new_meeting" do
      select "In person", from: :meeting_type_of_meeting
      expect(page).to have_field("Address")
      expect(page).to have_field(:meeting_location_en)
      expect(page).to have_no_field("Online meeting URL")

      select "Online", from: :meeting_type_of_meeting
      expect(page).to have_no_field("Address")
      expect(page).to have_no_field(:meeting_location_en)
      expect(page).to have_field("Online meeting URL")

      select "Hybrid", from: :meeting_type_of_meeting
      expect(page).to have_field("Address")
      expect(page).to have_field(:meeting_location_en)
      expect(page).to have_field("Online meeting URL")
    end
  end

  it "lets the user choose the registration type" do
    click_on "New meeting"

    within ".new_meeting" do
      select "Registration disabled", from: :meeting_registration_type
      expect(page).to have_no_field("Registration URL")

      select "On a different platform", from: :meeting_registration_type
      expect(page).to have_field("Registration URL")

      select "On this platform", from: :meeting_registration_type
      expect(page).to have_no_field("Registration URL")
    end
  end

  describe "soft deleting a meeting" do
    let!(:meeting2) { create(:meeting, component: current_component) }
    let(:admin_resource_path) { current_path }
    let(:trash_path) { "#{admin_resource_path}/meetings/manage_trash" }
    let(:title) { { en: "My new meeting" } }
    let!(:resource) { create(:meeting, component:, deleted_at:, title:) }
    let(:deleted_at) { nil }

    before do
      visit current_path
    end

    it "deletes a meeting" do
      within "tr", text: Decidim::Meetings::MeetingPresenter.new(meeting2).title do
        find("button[data-component='dropdown']").click
        accept_confirm { click_on "Soft delete" }
      end

      expect(page).to have_admin_callout("successfully")

      within "table" do
        expect(page).to have_no_content(Decidim::Meetings::MeetingPresenter.new(meeting2).title)
      end
    end

    it_behaves_like "manage soft deletable resource", "meeting"
    it_behaves_like "manage trashed resource", "meeting"
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
      within "tr", text: Decidim::Meetings::MeetingPresenter.new(meeting).title do
        find("button[data-component='dropdown']").click
        click_on "Edit"
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

    it "does not display error message when opening meeting's create form" do
      click_on "New meeting"

      within "label[for='meeting_registration_type']" do
        expect(page).to have_no_content("There is an error in this field.")
      end
    end

    it "creates a new meeting", :slow do
      click_on "New meeting"

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

      fill_in_datepicker :meeting_start_time_date, with: meeting_start_date
      fill_in_timepicker :meeting_start_time_time, with: meeting_start_time
      fill_in_datepicker :meeting_end_time_date, with: meeting_end_date
      fill_in_timepicker :meeting_end_time_time, with: meeting_end_time

      select decidim_sanitize_translated(taxonomy.name), from: "taxonomies-#{taxonomy_filter.id}"

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
    let!(:proposals) { create_list(:proposal, 3, component: proposal_component) }

    before do
      stub_geocoding_coordinates([meeting.latitude, meeting.longitude])
    end

    it "closes a meeting with a report" do
      within "tr", text: Decidim::Meetings::MeetingPresenter.new(meeting).title do
        find("button[data-component='dropdown']").click
        click_on "Close"
      end

      within ".edit_close_meeting" do
        expect(page).to have_content "Proposals"

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

        tom_select("#proposals_list", option_id: proposals.first(2).map(&:id))

        check "Is visible"
        click_on "Close"
      end

      expect(page).to have_admin_callout("Meeting successfully closed")

      within "tr", text: Decidim::Meetings::MeetingPresenter.new(meeting).title do
        expect(page).to have_content("Yes")
      end

      meeting.reload
      meeting.update(closing_report: {
                       en: %(The meeting was great! <img src="https://www.example.org/foobar.png" />),
                       es: "El encuentro fue genial",
                       ca: "La trobada va ser genial"
                     })

      visit decidim_participatory_process_meetings.meeting_path(
        participatory_process_slug: meeting.participatory_space.slug,
        component_id: meeting.component.id,
        id: meeting.id
      )

      within ".meeting__agenda-item__description" do
        expect(page).to have_css("img")
      end
    end

    context "when there are existing validated registrations" do
      let!(:not_attended_registrations) { create_list(:registration, 3, meeting:, validated_at: nil) }
      let!(:attended_registrations) { create_list(:registration, 2, meeting:, validated_at: Time.current) }

      before do
        within "tr", text: Decidim::Meetings::MeetingPresenter.new(meeting).title do
          find("button[data-component='dropdown']").click
          click_on "Close"
        end
      end

      it "displays by default the number of validated registrations" do
        within "form.edit_close_meeting" do
          expect(page).to have_field :close_meeting_attendees_count, with: "2"
        end
      end
    end

    context "when a meeting has already been closed" do
      let!(:meeting) { create(:meeting, :closed, component: current_component) }

      it "can update the information" do
        within "tr", text: Decidim::Meetings::MeetingPresenter.new(meeting).title do
          find("button[data-component='dropdown']").click
          click_on "Close"
        end

        within ".edit_close_meeting" do
          fill_in :close_meeting_attendees_count, with: 22
          click_on "Close"
        end

        expect(page).to have_admin_callout("Meeting successfully closed")
      end
    end

    context "when the proposal module is not installed" do
      before do
        allow(Decidim).to receive(:module_installed?).and_return(false)
      end

      it "does not display the proposal picker" do
        within "tr", text: Decidim::Meetings::MeetingPresenter.new(meeting).title do
          find("button[data-component='dropdown']").click
          click_on "Close"
        end

        expect(page).to have_content "Close meeting"

        within "form.edit_close_meeting" do
          expect(page).to have_no_content "Proposals"
        end
      end
    end
  end

  private

  def fill_in_services
    2.times { click_on "Add service" }

    page.all(".meeting-service").each_with_index do |meeting_service, index|
      within meeting_service do
        fill_in current_scope.find("[id$=title_en]", visible: :visible)["id"], with: service_titles[index]
      end
    end
  end
end
