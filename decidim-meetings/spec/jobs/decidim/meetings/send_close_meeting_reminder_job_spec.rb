# frozen_string_literal: true

require "spec_helper"

describe Decidim::Meetings::SendCloseMeetingReminderJob do
  subject { described_class }

  let(:organization) { create(:organization) }
  let(:participatory_process) { create(:participatory_process, organization:) }
  let(:component) { create(:component, :published, manifest_name: :meetings, participatory_space: participatory_process) }
  let(:user) { create(:user, organization:, email: "user@example.org") }
  let(:reminder) { create(:reminder, user:, component:) }
  let(:mailer) { double :mailer }
  let(:mailer_class) { Decidim::Meetings::CloseMeetingReminderMailer }

  context "when everything is OK" do
    let(:meeting) { create(:meeting, :published, component:) }
    let!(:reminder_record) { create(:reminder_record, reminder:, remindable: meeting) }

    it "sends an email and creates reminder delivery" do
      allow(mailer_class)
        .to receive(:close_meeting_reminder).with(reminder_record).and_return(mailer)
      expect(mailer)
        .to receive(:deliver_now)

      expect { subject.perform_now(reminder_record) }.to change(Decidim::ReminderDelivery, :count).to(1)
    end
  end

  context "when the meeting is closed" do
    let(:meeting) { create(:meeting, :published, :closed, component:) }
    let!(:reminder_record) { create(:reminder_record, reminder:, remindable: meeting) }

    it "doesn't send the email" do
      expect(mailer_class)
        .not_to receive(:close_meeting_reminder)

      subject.perform_now(reminder_record)
    end
  end
end
