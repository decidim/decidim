# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings
  describe CloseMeetingReminderMailer, type: :mailer do
    include ActionView::Helpers::SanitizeHelper

    let(:organization) { create(:organization) }
    let(:participatory_process) { create(:participatory_process, organization:) }
    let(:component) { create(:component, :published, manifest_name: :meetings, participatory_space: participatory_process) }
    let(:user) { create(:user, organization:, email: "user@example.org") }
    let(:meeting) { create(:meeting, :published, component:) }
    let(:reminder) { create(:reminder, user:, component:) }
    let!(:reminder_record) { create(:reminder_record, reminder:, remindable: meeting) }

    describe "when sending the email" do
      let(:mail) { described_class.close_meeting_reminder(reminder_record) }

      it "sends to the correct email address" do
        expect(mail.to).to eq(["user@example.org"])
      end

      it "parses the subject" do
        expect(mail.subject).to eq("You can now close your meeting with a report on the #{organization.name} platform")
      end
    end
  end
end
