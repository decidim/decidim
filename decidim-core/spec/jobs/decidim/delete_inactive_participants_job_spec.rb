# frozen_string_literal: true

require "spec_helper"

describe Decidim::DeleteInactiveParticipantsJob do
  subject { described_class }

  let(:organization) { create(:organization) }
  let!(:user) { create(:user, organization:, created_at:, current_sign_in_at:, extended_data:) }

  before do
    Decidim.delete_inactive_users_after_days = 300
    allow(Decidim::ParticipantsAccountMailer).to receive(:inactivity_notification).and_return(double(deliver_later: true))
    allow(Decidim::ParticipantsAccountMailer).to receive(:removal_notification).and_return(double(deliver_later: true))
  end

  describe "#perform" do
    context "when the user has never signed in and was registered before inactivity period" do
      let(:created_at) { 400.days.ago }
      let(:current_sign_in_at) { nil }
      let(:extended_data) { {} }

      it "sets first warning in extended_data and sends first notification" do
        perform_enqueued_jobs { subject.perform_later(organization) }

        expect(user.reload.extended_data["inactivity_notification"]).to include("notification_type" => "first")
        expect(Decidim::ParticipantsAccountMailer).to have_received(:inactivity_notification).with(user, 30).once
      end
    end

    context "when the user has never signed in and was registered after inactivity period" do
      let(:created_at) { 200.days.ago }
      let(:current_sign_in_at) { nil }
      let(:extended_data) { {} }

      it "does not set inactivity_notification in extended_data or send notification" do
        perform_enqueued_jobs { subject.perform_later(organization) }

        expect(user.reload.extended_data["inactivity_notification"]).to be_nil
        expect(Decidim::ParticipantsAccountMailer).not_to have_received(:inactivity_notification)
      end
    end

    context "when the user was inactive for 270 days" do
      let(:created_at) { 400.days.ago }
      let(:current_sign_in_at) { 270.days.ago }
      let(:extended_data) { {} }

      it "sets first warning in extended_data and sends first notification" do
        perform_enqueued_jobs { subject.perform_later(organization) }

        expect(user.reload.extended_data["inactivity_notification"]).to include("notification_type" => "first")
        expect(Decidim::ParticipantsAccountMailer).to have_received(:inactivity_notification).with(user, 30).once
      end
    end

    context "when the user has recently signed in" do
      let(:created_at) { 400.days.ago }
      let(:current_sign_in_at) { 10.days.ago }
      let(:extended_data) { {} }

      it "does not set inactivity_notification in extended_data or send notification" do
        perform_enqueued_jobs { subject.perform_later(organization) }

        expect(user.reload.extended_data["inactivity_notification"]).to be_nil
        expect(Decidim::ParticipantsAccountMailer).not_to have_received(:inactivity_notification)
      end
    end

    context "when the user received first warning and should get second warning" do
      let(:created_at) { 400.days.ago }
      let(:current_sign_in_at) { 370.days.ago }
      let(:extended_data) do
        {
          "inactivity_notification" => { "notification_type" => "first", "sent_at" => 23.days.ago.to_s }
        }
      end

      it "updates extended_data to second warning and sends final notification" do
        perform_enqueued_jobs { subject.perform_later(organization) }

        expect(user.reload.extended_data["inactivity_notification"]).to include("notification_type" => "second")
        expect(Decidim::ParticipantsAccountMailer).to have_received(:inactivity_notification).with(user, 7).once
      end
    end

    context "when the user is ready for deletion" do
      let(:created_at) { 400.days.ago }
      let(:current_sign_in_at) { 400.days.ago }
      let!(:email) { user.email }
      let!(:name) { user.name }
      let!(:locale) { user.locale }
      let(:extended_data) do
        {
          "inactivity_notification" => { "notification_type" => "second", "sent_at" => 8.days.ago.to_s }
        }
      end

      it "removes the user and sends deletion notification" do
        perform_enqueued_jobs { subject.perform_later(organization) }

        expect(user.reload.email).to be_empty
        expect(Decidim::ParticipantsAccountMailer).to have_received(:removal_notification).with(email, name, locale, organization).once
      end
    end
  end
end
