# frozen_string_literal: true

require "spec_helper"

describe Decidim::DeleteInactiveParticipantsJob do
  subject { described_class }

  let!(:organization) { create(:organization) }

  let!(:inactive_never_signed_in) { create(:user, organization: organization, last_sign_in_at: nil, created_at: 400.days.ago) }
  let!(:active_never_signed_in) { create(:user, organization: organization, last_sign_in_at: nil, created_at: 200.days.ago) }
  let!(:inactive_just_270_days) { create(:user, organization: organization, last_sign_in_at: 270.days.ago, created_at: 400.days.ago) }
  let!(:inactive_recent_sign_in) { create(:user, organization: organization, last_sign_in_at: 400.days.ago, created_at: 400.days.ago) }
  let!(:active_recent_sign_in) { create(:user, organization: organization, last_sign_in_at: 200.days.ago, created_at: 400.days.ago) }
  let!(:removal_pending_user) { create(:user, organization: organization, removal_date: 7.days.from_now, last_inactivity_notice_sent_at: nil, created_at: 400.days.ago) }
  let!(:reminder_sent_user) { create(:user, organization: organization, removal_date: 7.days.from_now, last_inactivity_notice_sent_at: 10.days.ago, created_at: 400.days.ago) }
  let!(:user_ready_for_deletion) { create(:user, organization: organization, removal_date: 1.day.ago, created_at: 400.days.ago) }

  before do
    Decidim.inactivity_period = 300
    allow(Decidim::ParticipantsAccountMailer).to receive(:inactivity_notification).and_return(double(deliver_later: true))
    allow(Decidim::ParticipantsAccountMailer).to receive(:removal_notification).and_return(double(deliver_later: true))
  end

  shared_examples "assigns removal date and sends 30-day notifications" do |user_context, should_assign_date, should_send_notification|
    let(:user) { send(user_context) }

    it "assigns removal date and sends notification if applicable" do
      perform_enqueued_jobs { subject.perform_later(organization) }

      if should_assign_date
        expect(user.reload.removal_date).not_to be_nil
      else
        expect(user.reload.removal_date).to be_nil
      end

      if should_send_notification
        expect(Decidim::ParticipantsAccountMailer).to have_received(:inactivity_notification).with(user, 30).once
      else
        expect(Decidim::ParticipantsAccountMailer).not_to have_received(:inactivity_notification).with(user, 30)
      end
    end
  end

  shared_examples "sends 7-day reminders" do |user_context, should_send_reminder|
    let(:user) { send(user_context) }

    it "sends 7-day reminders if applicable" do
      perform_enqueued_jobs { subject.perform_later(organization) }

      if should_send_reminder
        expect(user.reload.last_inactivity_notice_sent_at).not_to be_nil
        expect(Decidim::ParticipantsAccountMailer).to have_received(:inactivity_notification).with(user, 7).once
      else
        expect(user.reload.last_inactivity_notice_sent_at).to eq(user.last_inactivity_notice_sent_at)
        expect(Decidim::ParticipantsAccountMailer).not_to have_received(:inactivity_notification).with(user, 7)
      end
    end
  end

  shared_examples "removes users and sends deletion notifications" do |user_context, should_remove|
    let(:user) { send(user_context) }

    it "removes users and sends deletion notifications if applicable" do
      perform_enqueued_jobs { subject.perform_later(organization) }

      if should_remove
        expect(user.reload.email).to be_empty
        expect(Decidim::ParticipantsAccountMailer).to have_received(:removal_notification).with(user).once
      else
        expect(user.reload.email).not_to be_empty
        expect(Decidim::ParticipantsAccountMailer).not_to have_received(:removal_notification).with(user)
      end
    end
  end

  describe "#perform" do
    context "when assigning removal dates" do
      it_behaves_like "assigns removal date and sends 30-day notifications", :inactive_just_270_days, true, true
      it_behaves_like "assigns removal date and sends 30-day notifications", :inactive_never_signed_in, true, true
      it_behaves_like "assigns removal date and sends 30-day notifications", :active_never_signed_in, false, false
      it_behaves_like "assigns removal date and sends 30-day notifications", :inactive_recent_sign_in, true, true
      it_behaves_like "assigns removal date and sends 30-day notifications", :active_recent_sign_in, false, false
    end

    context "when sending reminders 7 days before removal" do
      it_behaves_like "sends 7-day reminders", :inactive_just_270_days, false
      it_behaves_like "sends 7-day reminders", :reminder_sent_user, true
      it_behaves_like "sends 7-day reminders", :removal_pending_user, false
    end

    context "when removing inactive users" do
      it_behaves_like "removes users and sends deletion notifications", :user_ready_for_deletion, true

      it "does not remove users who are not ready for deletion" do
        [
          inactive_never_signed_in,
          active_never_signed_in,
          inactive_recent_sign_in,
          active_recent_sign_in,
          removal_pending_user,
          reminder_sent_user
        ].each do |user|
          expect(user.reload.email).not_to be_empty
        end
      end
    end

    context "when users log in after receiving notifications" do
      let!(:user_logged_in_after_notification) do
        create(
          :user,
          organization:,
          last_sign_in_at: 1.day.ago,
          removal_date: 15.days.from_now,
          last_inactivity_notice_sent_at: 5.days.ago,
          created_at: 400.days.ago
        )
      end

      it "resets removal_date and last_inactivity_notice_sent_at" do
        perform_enqueued_jobs { subject.perform_later(organization) }

        expect(user_logged_in_after_notification.reload.removal_date).to be_nil
        expect(user_logged_in_after_notification.reload.last_inactivity_notice_sent_at).to be_nil
      end
    end
  end
end
