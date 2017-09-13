# frozen_string_literal: true

require "spec_helper"

describe Decidim::Meetings::RegistrationMailer, type: :mailer do
  include ActionView::Helpers::SanitizeHelper

  let(:organization) { create(:organization) }
  let(:participatory_process) { create(:participatory_process, organization: organization) }
  let(:feature) { create(:feature, manifest_name: :meetings, participatory_space: participatory_process) }
  let(:user) { create(:user, organization: organization) }
  let(:meeting) { create(:meeting, feature: feature) }
  let(:mail) { described_class.confirmation(user, meeting) }

  describe "confirmation" do
    let(:subject) { "La teva inscripció a la trobada ha estat confirmada" }
    let(:default_subject) { "Your meeting's registration has been confirmed" }

    let(:body) { "detalls de la" }
    let(:default_body) { "details in the attachment" }

    include_examples "user localised email"
  end

  it "includes the meeting's details in a ics file" do
    expect(mail.attachments.length).to eq(1)
    attachment = mail.attachments.first
    expect(attachment.filename).to match(/meeting-calendar-info.ics/)

    events = Icalendar::Event.parse(attachment.read)
    event = events.first
    expect(event.summary).to eq(translated(meeting.title))
    expect(event.description).to eq(strip_tags(translated(meeting.description)))
    expect(event.dtstart.value.to_i).to eq(Icalendar::Values::DateTime.new(meeting.start_time).value.to_i)
    expect(event.dtend.value.to_i).to eq(Icalendar::Values::DateTime.new(meeting.end_time).value.to_i)
    expect(event.geo).to eq([meeting.latitude, meeting.longitude])
  end
end
