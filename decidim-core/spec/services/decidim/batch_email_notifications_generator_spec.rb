# frozen_string_literal: true

require "spec_helper"

describe Decidim::BatchEmailNotificationsGenerator do
  include ActionView::Helpers::DateHelper
  subject { described_class.new }

  let!(:user) { create(:user) }
  let!(:notifications) { create_list(:notification, 5, user: user) }
  let(:serialized_event) do
    {
      resource: notifications.first.resource,
      event_class: notifications.first.event_class,
      event_name: notifications.first.event_name,
      user: notifications.first.user,
      extra: notifications.first.extra,
      user_role: notifications.first.user_role,
      created_at: time_ago_in_words(notifications.first.created_at).capitalize
    }
  end

  describe "generate" do
    let(:mailer) { double(deliver_later: true) }

    it "enqueues the job" do
      expect(Decidim::BatchNotificationsMailer)
        .to receive(:event_received)
        .with(subject.send(:serialized_events, subject.send(:events_for, user)), user)
        .and_return(mailer)

      expect(mailer).to receive(:deliver_later)

      subject.generate
    end

    it "marks the notifications has sent" do
      expect(notifications.map(&:sent_at).any?).to eq(false)
    end

    context "when user doesn't want to receive email notification" do
      let!(:user) { create(:user, email_on_notification: false) }

      it "doesn't schedule a job for each recipient" do
        expect(Decidim::BatchNotificationsMailer)
          .not_to receive(:event_received)

        subject.generate
      end
    end

    context "when there is no events" do
      let(:notifications) { nil }

      it "doesn't schedule a job for each recipient" do
        expect(Decidim::BatchNotificationsMailer)
          .not_to receive(:event_received)

        subject.generate
      end
    end
  end

  describe "#events" do
    it "returns notifications" do
      expect(subject.send(:events)).to match_array(notifications)
      expect(subject.send(:events).length).to eq(5)
    end

    context "when batch_email_notifications_max_length" do
      it "limit the number of notifications" do
        Decidim.config.batch_email_notifications_max_length = 1

        expect(subject.send(:events)).to match_array(notifications.last)
        expect(subject.send(:events).length).to eq(1)
      end
    end

    context "when notifications has already been sent" do
      let!(:notifications) { create_list(:notification, 5, user: user) }

      it "doesn't includes it" do
        notifications.first.update!(sent_at: 12.hours.ago)

        expect(subject.send(:events)).not_to include(notifications.first)
        expect(subject.send(:events).length).to eq(4)
      end
    end
  end

  describe "#events_for" do
    let(:another_user) { create(:user) }
    let(:notification) { create(:notification, user: another_user) }

    it "returns notifications for user" do
      expect(subject.send(:events_for, user)).not_to include(notification)
      expect(subject.send(:events_for, user)).to match_array(notifications)
      expect(subject.send(:events_for, user).length).to eq(5)
    end
  end

  describe "#users" do
    it "returns users id" do
      expect(subject.send(:users)).to eq([user.id])
    end
  end

  describe "#serialized_events" do
    it "returns serialized events" do
      expect(subject.send(:serialized_events, [notifications.first]))
        .to eq([serialized_event])
    end
  end

  describe "#mark_as_sent" do
    it "updates notifications" do
      subject.send(:mark_as_sent, subject.send(:events))
      expect(notifications.map(&:sent_at).any?).to eq(false)
    end
  end
end
