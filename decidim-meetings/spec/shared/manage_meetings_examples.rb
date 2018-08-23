# frozen_string_literal: true

shared_examples "manage meetings" do
  let(:address) { "Carrer Pare Llaurador 113, baixos, 08224 Terrassa" }
  let(:latitude) { 40.1234 }
  let(:longitude) { 2.1234 }

  let(:organizer) { create(:user, :confirmed, organization: organization) }
  let(:service_titles) { ["This is the first service", "This is the second service"] }

  before do
    stub_geocoding(address, [latitude, longitude])
  end

  it "updates a meeting" do
    within find("tr", text: translated(meeting.title)) do
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

  it "adds a few services to the meeting" do
    within find("tr", text: translated(meeting.title)) do
      click_link "Edit"
    end

    within ".edit_meeting" do
      fill_in :meeting_address, with: address
      fill_in_services

      expect(page).to have_selector(".meeting-service", count: 2)

      find("*[type=submit]").click
    end

    expect(page).to have_admin_callout("successfully")

    within find("tr", text: translated(meeting.title)) do
      click_link "Edit"
    end

    expect(page).to have_selector("input[value='This is the first service']")
    expect(page).to have_selector("input[value='This is the second service']")
  end

  it "allows the user to preview the meeting" do
    within find("tr", text: translated(meeting.title)) do
      klass = "action-icon--preview"
      href = resource_locator(meeting).path
      target = "blank"

      expect(page).to have_selector(
        :xpath,
        "//a[contains(@class,'#{klass}')][@href='#{href}'][@target='#{target}']"
      )
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
    fill_in_services

    page.execute_script("$('#datetime_field_meeting_start_time').focus()")
    page.find(".datepicker-dropdown .day", text: "12").click
    page.find(".datepicker-dropdown .hour", text: "10:00").click
    page.find(".datepicker-dropdown .minute", text: "10:50").click

    page.execute_script("$('#datetime_field_meeting_end_time').focus()")
    page.find(".datepicker-dropdown .day", text: "12").click
    page.find(".datepicker-dropdown .hour", text: "12:00").click
    page.find(".datepicker-dropdown .minute", text: "12:50").click

    scope_pick select_data_picker(:meeting_decidim_scope_id), scope
    select translated(category.name), from: :meeting_decidim_category_id

    autocomplete_select "#{organizer.name} (@#{organizer.nickname})", from: :organizer_id

    within ".new_meeting" do
      find("*[type=submit]").click
    end

    expect(page).to have_admin_callout("successfully")

    within "table" do
      expect(page).to have_content("My meeting")
    end
  end

  describe "duplicating a meeting" do
    it "creates a new meeting", :slow do
      within find("tr", text: translated(meeting.title)) do
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

      fill_in :meeting_address, with: address

      page.execute_script("$('#datetime_field_meeting_start_time').focus()")
      page.find(".datepicker-dropdown .day", text: "12").click
      page.find(".datepicker-dropdown .hour", text: "10:00").click
      page.find(".datepicker-dropdown .minute", text: "10:50").click

      page.execute_script("$('#datetime_field_meeting_end_time').focus()")
      page.find(".datepicker-dropdown .day", text: "12").click
      page.find(".datepicker-dropdown .hour", text: "12:00").click
      page.find(".datepicker-dropdown .minute", text: "12:50").click

      autocomplete_select "#{organizer.name} (@#{organizer.nickname})", from: :organizer_id

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
      within find("tr", text: translated(meeting2.title)) do
        accept_confirm { click_link "Delete" }
      end

      expect(page).to have_admin_callout("successfully")

      within "table" do
        expect(page).to have_no_content(translated(meeting2.title))
      end
    end
  end

  context "when geocoding is disabled" do
    before do
      allow(Decidim).to receive(:geocoder).and_return(nil)
    end

    it "updates a meeting" do
      within find("tr", text: translated(meeting.title)) do
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
      page.execute_script("$('#datetime_field_meeting_start_time').focus()")
      page.find(".datepicker-dropdown .day", text: "12").click
      page.find(".datepicker-dropdown .hour", text: "10:00").click
      page.find(".datepicker-dropdown .minute", text: "10:50").click

      page.execute_script("$('#datetime_field_meeting_end_time').focus()")
      page.find(".datepicker-dropdown .day", text: "12").click
      page.find(".datepicker-dropdown .hour", text: "12:00").click
      page.find(".datepicker-dropdown .minute", text: "12:50").click

      scope_pick select_data_picker(:meeting_decidim_scope_id), scope
      select translated(category.name), from: :meeting_decidim_category_id

      autocomplete_select "#{organizer.name} (@#{organizer.nickname})", from: :organizer_id

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

    it "closes a meeting with a report" do
      within find("tr", text: translated(meeting.title)) do
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
        select proposals.first.title, from: :close_meeting_proposal_ids
        click_button "Close"
      end

      expect(page).to have_admin_callout("Meeting successfully closed")

      within find("tr", text: translated(meeting.title)) do
        expect(page).to have_content("Yes")
      end
    end

    context "when a meeting has alredy been closed" do
      let!(:meeting) { create(:meeting, :closed, component: current_component) }

      it "can update the information" do
        within find("tr", text: translated(meeting.title)) do
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
        fill_in current_scope.find("[id$=title_en]", visible: true)["id"], with: service_titles[index]
      end
    end
  end
end
