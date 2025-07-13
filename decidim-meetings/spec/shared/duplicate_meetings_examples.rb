# frozen_string_literal: true

shared_examples "duplicate meetings" do
  let(:form) { Decidim::Meetings::Admin::MeetingForm.from_model(meeting).with_context(context) }
  let(:context) { { current_organization: meeting.organization, current_component: meeting.component } }
  let(:copy_meeting) { Decidim::Meetings::Admin::CopyMeeting.new(form, meeting) }

  let(:latitude) { meeting.latitude }
  let(:longitude) { meeting.longitude }
  let(:meetings_path) { Decidim::EngineRouter.admin_proxy(meeting.component).meetings_path }

  let(:duplicated_meeting) { Decidim::Meetings::Meeting.find_by("title->>'en' = 'Duplicated meeting'") }
  let(:edit_duplicated_meeting_registrations_form_path) do
    Decidim::EngineRouter.admin_proxy(component).edit_meeting_registrations_form_path(duplicated_meeting.id)
  end

  before do
    stub_geocoding(meeting.address, [latitude, longitude])
    form.title["en"] = "Duplicated meeting"
  end

  it "duplicates a meeting" do
    visit meetings_path

    within "tr", text: translated(meeting.title) do
      find("button[data-component='dropdown']").click
      click_on "Duplicate"
    end
    click_on "Copy"

    expect(page).to have_content("Meeting successfully duplicated.")
  end

  it "allows to edit the registration form of the duplicated meeting" do
    copy_meeting.call
    visit edit_duplicated_meeting_registrations_form_path
    fill_in :questionnaire_title_en, with: "Title"
    fill_in_i18n_editor(:questionnaire_tos, "#questionnaire-tos-tabs", en: "ToS", ca: "ToS", es: "ToS")
    click_on "Save"

    expect(page).to have_content("Form successfully saved.")
  end
end
