# frozen_string_literal: true

shared_examples_for "event notification" do
  describe "event" do
    context "when a notificable event takes place" do
      let!(:organization) { create(:organization) }
      let(:user) { create(:user, organization:, notifications_sending_frequency: "daily", locale: "en") }

      it "sends a notification to the user's email" do
        perform_enqueued_jobs do
          expect(command.call).to broadcast(:ok)
          # raise Decidim::Notification.all.inspect
          Decidim::Notification.last.update(created_at: 1.day.ago)
          Decidim::EmailNotificationsDigestGeneratorJob.perform_now(user.id, "daily")
        end

        expect(last_email_body.length).to be_positive
        expect(last_email_body).not_to include("translation missing")
      end
    end
  end
end
