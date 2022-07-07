# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings
  describe RegistrationMailer, type: :mailer do
    include ActionView::Helpers::SanitizeHelper

    let(:organization) { create(:organization) }
    let(:participatory_process) { create(:participatory_process, organization: organization) }
    let(:component) { create(:component, manifest_name: :meetings, participatory_space: participatory_process) }
    let(:user) { create(:user, organization: organization) }
    let(:meeting) { create(:meeting, component: component) }
    let(:registration) { create(:registration, meeting: meeting, user: user) }
    let(:mail) { described_class.confirmation(user, meeting, registration) }

    describe "confirmation" do
      let(:mail_subject) { "La teva inscripció a la trobada ha estat confirmada" }
      let(:default_subject) { "Your meeting's registration has been confirmed" }

      let(:body) { "arxiu adjunt" }
      let(:default_body) { "You will find the meeting" }

      include_examples "localised email"
    end

    context "when registration code is enabled" do
      before do
        component.update!(settings: { registration_code_enabled: true })
      end

      it "includes the registration code" do
        expect(email_body(mail)).to match("Your registration code is #{registration.code}")
      end
    end

    context "when registration code is disabled" do
      before do
        component.update!(settings: { registration_code_enabled: false })
      end

      it "does not include the registration code" do
        expect(email_body(mail)).not_to match("Your registration code is #{registration.code}")
      end
    end

    describe "custom content" do
      context "when custom content is enabled" do
        before do
          meeting.customize_registration_email = true
          meeting.registration_email_custom_content = { "en" => "Customized registration email content" }
        end

        it "includes the customized content" do
          expect(email_body(mail)).to match("Customized registration email content")
        end
      end

      context "when custom content is disabled" do
        it "does not include the customized content" do
          expect(email_body(mail)).not_to match("Customized registration email content")
        end
      end
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
end
