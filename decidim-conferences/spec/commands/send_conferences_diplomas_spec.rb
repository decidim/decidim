# frozen_string_literal: true

require "spec_helper"

module Decidim::Conferences
  describe Admin::SendConferenceDiplomas do
    describe "call" do
      let(:my_conference) { create :conference, :diploma }
      let(:user) { create :user, :admin, :confirmed, organization: my_conference.organization }
      let(:user_not_admin) { create :user, :confirmed, organization: my_conference.organization }

      let!(:conference_registration) { create :conference_registration, conference: my_conference, user: user_not_admin }

      let(:command) { described_class.new(my_conference, user) }

      describe "when the diploma already sent" do
        before do
          my_conference.diploma_sent_at = Time.current
        end

        it "broadcasts invalid" do
          expect { command.call }.to broadcast(:invalid)
        end
      end

      describe "when diplomas wasn't sent" do
        it "broadcasts ok" do
          expect { command.call }.to broadcast(:ok)
        end

        it "updates the conference diploma sent at date" do
          command.call
          my_conference.reload

          expect(my_conference.diploma_sent_at).not_to be_nil
        end

        it "sends an email with diploma as attachment" do
          perform_enqueued_jobs { command.call }

          email = last_email

          expect(email.subject).to include("Your conference certificate of attendance has been sent")

          attachment = email.attachments.first
          expect(attachment.read.length).to be_positive
          expect(attachment.filename).to match("conference-#{user_not_admin.nickname.parameterize}-diploma.pdf")
        end

        it "traces the action", versioning: true do
          expect(Decidim.traceability)
            .to receive(:perform_action!)
            .with(:send_conference_diplomas, my_conference, user)
            .and_call_original

          expect { command.call }.to change(Decidim::ActionLog, :count)
          action_log = Decidim::ActionLog.last
          expect(action_log.version).to be_present
        end
      end
    end
  end
end
