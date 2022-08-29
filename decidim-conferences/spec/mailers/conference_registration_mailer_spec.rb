# frozen_string_literal: true

require "spec_helper"

module Decidim::Conferences
  describe ConferenceRegistrationMailer, type: :mailer do
    include ActionView::Helpers::SanitizeHelper
    include Decidim::TranslationsHelper

    let(:organization) { create(:organization) }
    let(:conference) { create(:conference, organization:) }
    let(:user) { create(:user, organization:) }
    let(:registration_type) { create(:registration_type, conference:) }
    let(:conference_registration) { create(:conference_registration, conference:, registration_type:, user:) }
    let(:mail_pending) { described_class.pending_validation(user, conference, registration_type) }
    let(:mail) { described_class.confirmation(user, conference, registration_type) }

    describe "pending validation" do
      let(:default_subject) { "Your conference's registration is pending confirmation" }

      let(:default_body) { "You will receive the confirmation shortly" }

      it "expect subject and body" do
        expect(mail_pending.subject).to eq(default_subject)
        expect(mail_pending.body.encoded).to match(default_body)
      end
    end

    describe "confirmation" do
      let(:default_subject) { "Your conference's registration has been confirmed" }

      let(:default_body) { "You will find the conference" }

      it "expect subject and body" do
        expect(mail.subject).to eq(default_subject)
        expect(mail.body.encoded).to match(default_body)
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
end
