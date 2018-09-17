# frozen_string_literal: true

require "spec_helper"

module Decidim::Conferences
  describe ConferenceRegistrationMailer, type: :mailer do
    include ActionView::Helpers::SanitizeHelper

    let(:organization) { create(:organization) }
    let(:conference) { create(:conference, organization: organization) }
    let(:user) { create(:user, organization: organization) }
    let(:conference_registration) { create(:conference_registration, conference: conference, user: user) }
    let(:mail) { described_class.confirmation(user, conference) }

    describe "confirmation" do
      let(:default_subject) { "Your conference's registration has been confirmed" }

      let(:default_body) { "details in the attachment" }

      it "expect subject and body" do
        expect(mail.subject).to eq(default_subject)
        expect(mail.body.encoded).to match(default_body)
      end
    end

    it "includes the conference's details in a ics file" do
      expect(mail.attachments.length).to eq(1)
      attachment = mail.attachments.first
      expect(attachment.filename).to match(/conference-calendar-info.ics/)

      events = Icalendar::Event.parse(attachment.read)
      event = events.first
      expect(event.summary).to eq(translated(conference.title))
      expect(event.description).to eq(strip_tags(translated(conference.description)))
      expect(event.dtstart.value.to_i).to eq(Icalendar::Values::DateTime.new(conference.start_date).value.to_i)
      expect(event.dtend.value.to_i).to eq(Icalendar::Values::DateTime.new(conference.end_date).value.to_i)
    end
  end
end
