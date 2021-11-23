# frozen_string_literal: true

require "spec_helper"

describe "decidim_meetings:close_meeting_notification", type: :task do
  let!(:organization) { create :organization }
  let!(:participatory_process) { create :participatory_process, organization: organization }
  let!(:component) do
    create :component,
           :published,
           manifest_name: :meetings,
           participatory_space: participatory_process,
           settings: {
             enable_cr_initial_notifications: true,
             close_report_notifications: 2,
             enable_cr_reminder_notifications: true,
             close_report_reminder_notifications: 7
           }
  end
  let!(:mailer) { double :mailer }

  let!(:user) { create(:user, :confirmed, organization: organization) }

  let!(:meeting) do
    create(:meeting, :published, component: component, end_time: Time.current, author: user)
  end
  let!(:meeting_overdue1) do
    create(:meeting, :published, component: component, end_time: 2.days.ago, author: user)
  end

  it "preloads the Rails environment" do
    expect(task.prerequisites).to include "environment"
  end

  it "runs gracefully" do
    expect { task.execute }.not_to raise_error
  end

  describe "close report initial and reminder notifications are enabled" do
    context "when user has overdue meetings" do
      it "sends the first notification" do
        expect(Decidim::Meetings::CloseMeetingReminderMailer)
          .to receive(:first_notification)
          .with(meeting_overdue1, user)
          .and_return(mailer)
        expect(mailer)
          .to receive(:deliver_later)

        task.execute
      end
    end

    context "when user has overdue meetings" do
      let!(:meeting_overdue2) do
        create(:meeting, :published, component: component, end_time: 7.days.ago, author: user)
      end

      it "sends the reminder notification" do
        expect(Decidim::Meetings::CloseMeetingReminderMailer)
          .to receive(:reminder_notification)
          .with(meeting_overdue2, user)
          .and_return(mailer)
        expect(mailer)
          .to receive(:deliver_later)

        task.execute
      end
    end
  end

  describe "close report initial and reminder notifications are disabled" do
    context "when user has overdue meetings" do
      it "do not send the first notification" do
        component.update!(settings: { enable_cr_initial_notifications: false })
        expect(Decidim::Meetings::CloseMeetingReminderMailer)
          .not_to receive(:first_notification)
          .with(meeting_overdue1, user)

        task.execute
      end
    end

    context "when user has overdue meetings" do
      let!(:meeting_overdue2) do
        create(:meeting, :published, component: component, end_time: 7.days.ago, author: user)
      end

      it "do not send the reminder notification" do
        component.update!(settings: { enable_cr_reminder_notifications: false })
        expect(Decidim::Meetings::CloseMeetingReminderMailer)
          .not_to receive(:reminder_notification)
          .with(meeting_overdue2, user)

        task.execute
      end
    end
  end
end
