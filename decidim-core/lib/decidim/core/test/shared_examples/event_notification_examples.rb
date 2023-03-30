# frozen_string_literal: true

shared_examples_for "event notification" do
  describe "event" do
    context "when a notificable event takes place" do
      let!(:component) { build component_name }
      let!(:organization) { component.participatory_space.organization }
      let!(:user) { create(:user, organization:, notifications_sending_frequency: "daily") }
      let!(:record) { create(resource, component:, users: [user], title: { en: "Event notifier" }) }

      it "sends a notification to the user's email" do
        # case resource
        # when :proposal
        #   record.add_coauthor(user)
        #   record.save!
        # when :debate
        #   record.add_author(user)
        #   record.save!
        # end

        perform_enqueued_jobs do
          command.call
          # raise Decidim::Notification.all.inspect
          Decidim::Notification.last.update(created_at: "Tue, 28 Mar 2023 10:54:23.23 UTC +00:00")
          Decidim::EmailNotificationsDigestGeneratorJob.perform_now(user.id, "daily")
        end

        expect(last_email_body).not_to include("translation missing")
      end
    end
  end
end
