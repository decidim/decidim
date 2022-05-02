# frozen_string_literal: true

require "spec_helper"

module Decidim::Conferences
  describe Admin::SendConferenceDiplomaMailer, type: :mailer do
    include ActionView::Helpers::SanitizeHelper

    let(:organization) { create(:organization) }
    let(:conference) { create(:conference, :diploma, organization: organization) }
    let(:user) { create(:user, organization: organization) }
    let(:registration_type) { create(:registration_type, conference: conference) }
    let(:conference_registration) { create(:conference_registration, conference: conference, registration_type: registration_type, user: user) }
    let(:mail) { described_class.diploma(conference, user) }

    describe "diploma" do
      let(:mail_subject) { "has been sent" }
      let(:body) { "in the attachment" }

      it "expect subject and body" do
        expect(mail.subject).to include(mail_subject)
        expect(mail.body.encoded).to match(body)
      end
    end

    it "includes the meeting's details in a ics file" do
      expect(mail.attachments.length).to eq(1)
      attachment = mail.attachments.first
      expect(attachment.filename).to match("conference-#{user.nickname.parameterize}-diploma.pdf")
    end
  end
end
