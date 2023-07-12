# frozen_string_literal: true

shared_context "when sends the notification digest" do
  context "when daily notification mail" do
    let(:user) { create(:user, :admin, organization:, notifications_sending_frequency: "daily") }

    it_behaves_like "notification digest mail"
  end

  context "when weekly notification mail" do
    let(:user) { create(:user, :admin, organization:, notifications_sending_frequency: "weekly") }

    it_behaves_like "notification digest mail"
  end
end

shared_examples_for "notification digest mail" do
  context "when a notificable event takes place" do
    let!(:organization) { create(:organization) }
    let!(:participatory_space) { create(:participatory_process, organization:) }

    it "sends a notification to the user's email" do
      perform_enqueued_jobs do
        expect(command.call).to broadcast(:ok)
        Decidim::Notification.last.update(created_at: 1.day.ago)
        Decidim::EmailNotificationsDigestGeneratorJob.perform_now(user.id, user.notifications_sending_frequency)
      end

      expect(last_email_body.length).to be_positive
      expect(last_email_body).not_to include("translation missing")
    end
  end
end
