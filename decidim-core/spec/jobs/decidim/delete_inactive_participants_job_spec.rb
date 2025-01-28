# frozen_string_literal: true

require "spec_helper"

describe Decidim::DeleteInactiveParticipantsJob do
  subject { described_class }

  let(:organization) { create(:organization) }
  let!(:user) { create(:user, organization:, created_at:, last_sign_in_at:, marked_for_deletion_at:) }

  before do
    Decidim.inactivity_period_days = 300
    allow(Decidim::ParticipantsAccountMailer).to receive(:inactivity_notification).and_return(double(deliver_later: true))
    allow(Decidim::ParticipantsAccountMailer).to receive(:removal_notification).and_return(double(deliver_later: true))
  end

  describe "#perform" do
    context "when the user has never signed in and was registered before inactivity period" do
      let(:created_at) { 400.days.ago }
      let(:last_sign_in_at) { nil }
      let(:marked_for_deletion_at) { nil }

      it "assigns marked_for_deletion_at and sends 30-day notification" do
        perform_enqueued_jobs { subject.perform_later(organization) }

        expect(user.reload.marked_for_deletion_at).not_to be_nil
        expect(Decidim::ParticipantsAccountMailer).to have_received(:inactivity_notification).with(user, 30).once
      end
    end

    context "when the user has never signed in and was registered after inactivity period" do
      let(:created_at) { 200.days.ago }
      let(:last_sign_in_at) { nil }
      let(:marked_for_deletion_at) { nil }

      it "does not assign marked_for_deletion_at or send notification" do
        perform_enqueued_jobs { subject.perform_later(organization) }

        expect(user.reload.marked_for_deletion_at).to be_nil
        expect(Decidim::ParticipantsAccountMailer).not_to have_received(:inactivity_notification).with(user, 30)
      end
    end

    context "when the user was inactive for 270 days" do
      let(:created_at) { 400.days.ago }
      let(:last_sign_in_at) { 270.days.ago }
      let(:marked_for_deletion_at) { nil }

      it "assigns marked_for_deletion_at and sends 30-day notification" do
        perform_enqueued_jobs { subject.perform_later(organization) }

        expect(user.reload.marked_for_deletion_at).not_to be_nil
        expect(Decidim::ParticipantsAccountMailer).to have_received(:inactivity_notification).with(user, 30).once
      end
    end

    context "when the user has recently signed in" do
      let(:created_at) { 400.days.ago }
      let(:last_sign_in_at) { 10.days.ago }
      let(:marked_for_deletion_at) { nil }

      it "does not assign marked_for_deletion_at or send notification" do
        perform_enqueued_jobs { subject.perform_later(organization) }

        expect(user.reload.marked_for_deletion_at).to be_nil
        expect(Decidim::ParticipantsAccountMailer).not_to have_received(:inactivity_notification).with(user, 30)
      end
    end

    context "when the user is pending a reminder" do
      let(:created_at) { 400.days.ago }
      let(:last_sign_in_at) { 370.days.ago }
      let(:marked_for_deletion_at) { 23.days.ago }

      it "sends 7-day reminder notification" do
        perform_enqueued_jobs { subject.perform_later(organization) }

        expect(Decidim::ParticipantsAccountMailer).to have_received(:inactivity_notification).with(user, 7).once
      end
    end

    context "when the user is ready for deletion" do
      let(:created_at) { 400.days.ago }
      let(:last_sign_in_at) { 400.days.ago }
      let(:marked_for_deletion_at) { 31.days.ago }

      it "removes the user and sends deletion notification" do
        perform_enqueued_jobs { subject.perform_later(organization) }

        expect(user.reload.email).to be_empty
        expect(Decidim::ParticipantsAccountMailer).to have_received(:removal_notification).with(user).once
      end
    end

    context "when the user has signed in after receiving notifications" do
      let(:created_at) { 400.days.ago }
      let(:last_sign_in_at) { 1.day.ago }
      let(:marked_for_deletion_at) { 15.days.ago }

      it "resets marked_for_deletion_at" do
        perform_enqueued_jobs { subject.perform_later(organization) }

        expect(user.reload.marked_for_deletion_at).to be_nil
      end
    end
  end
end
