# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings
  describe CloseMeetingReminderGenerator do
    subject { described_class.new }

    let(:manifest) do
      double(
        settings: double(
          attributes: {
            reminder_times: double(default: intervals)
          }
        )
      )
    end
    let(:intervals) { [3.days, 7.days] }
    let(:organization) { create(:organization) }
    let(:participatory_process) { create(:participatory_process, organization: organization) }
    let(:component) { create(:component, :published, manifest_name: :meetings, participatory_space: participatory_process) }
    let(:user) { create(:user, :admin, organization: organization, email: "user@example.org") }
    let(:meeting_3) { create(:meeting, :published, component: component, author: user) }
    let(:meeting_7) { create(:meeting, :published, component: component, author: user) }

    before do
      allow(Decidim.reminders_registry).to receive(:for).with(:close_meeting).and_return(manifest)
    end

    describe "#generate" do
      context "when there is a past meeting without a report in the the last 3 days" do
        context "and the meeting is closed" do
          before do
            meeting_3.update!(start_time: 4.days.ago, end_time: 3.days.ago, closed_at: 2.days.ago)
          end

          it "does not send the reminder" do
            expect(Decidim::Meetings::SendCloseMeetingReminderJob).not_to receive(:perform_later)

            expect { subject.generate }.to change(Decidim::Reminder, :count).by(0)
          end
        end

        context "and the meeting is not closed" do
          before do
            meeting_3.update!(start_time: 4.days.ago, end_time: 3.days.ago)
          end

          it "sends reminder" do
            expect(Decidim::Meetings::SendCloseMeetingReminderJob).to receive(:perform_later)

            expect { subject.generate }.to change(Decidim::Reminder, :count).by(1)
          end
        end
      end

      context "when there is a past meeting without a report in the the last 7 days" do
        context "when the meeting is closed" do
          before do
            meeting_7.update!(start_time: 8.days.ago, end_time: 7.days.ago, closed_at: 2.days.ago)
          end

          it "does not send the reminder" do
            expect(Decidim::Meetings::SendCloseMeetingReminderJob).not_to receive(:perform_later)

            expect { subject.generate }.to change(Decidim::Reminder, :count).by(0)
            expect(Decidim::Reminder.first).to be_nil
          end
        end

        context "when the meeting is not closed" do
          before do
            meeting_7.update!(start_time: 8.days.ago, end_time: 7.days.ago)
          end

          it "sends reminder" do
            expect(Decidim::Meetings::SendCloseMeetingReminderJob).to receive(:perform_later)

            expect { subject.generate }.to change(Decidim::Reminder, :count).by(1)
            expect(Decidim::Reminder.first.records.count).to eq(1)
          end
        end
      end

      context "when the meeting is in the past but end date does not correspond to the interval" do
        let(:meeting_9) { create(:meeting, :published, component: component, author: user, start_time: 10.days.ago, end_time: 9.days.ago) }

        it "does not send the reminder" do
          expect(Decidim::Meetings::SendCloseMeetingReminderJob).not_to receive(:perform_later)

          expect { subject.generate }.to change(Decidim::Reminder, :count).by(0)
          expect(Decidim::Reminder.first).to be_nil
        end
      end

      context "when the reminder exists" do
        let!(:reminder) { create(:reminder, user: user, component: component) }

        before do
          meeting_3.update!(start_time: 4.days.ago, end_time: 3.days.ago)
        end

        it "sends existing reminder" do
          expect(Decidim::Meetings::SendCloseMeetingReminderJob).to receive(:perform_later)

          expect { subject.generate }.not_to change(Decidim::Reminder, :count)
        end
      end
    end
  end
end
