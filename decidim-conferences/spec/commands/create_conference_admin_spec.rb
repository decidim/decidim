# frozen_string_literal: true

require "spec_helper"

module Decidim::Conferences
  describe Admin::CreateConferenceAdmin do
    subject { described_class.new(form, current_user, my_conference) }

    let(:my_conference) { create :conference }
    let!(:email) { "my_email_conference@example.org" }
    let!(:role) { "admin" }
    let!(:name) { "Weird Guy Conference" }
    let!(:user) { create :user, email: "my_email_conference@example.org", organization: my_conference.organization }
    let!(:current_user) { create :user, email: "some_email_conference@example.org", organization: my_conference.organization }
    let(:form) do
      double(
        invalid?: invalid,
        email:,
        role:,
        name:,
        current_participatory_space: my_conference
      )
    end
    let(:invalid) { false }
    let(:user_notification) do
      {
        event: "decidim.events.conferences.role_assigned",
        event_class: ConferenceRoleAssignedEvent,
        resource: my_conference,
        affected_users: [user],
        extra: { role: kind_of(String) }
      }
    end

    context "when the form is not valid" do
      let(:invalid) { true }

      it "is not valid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when everything is ok" do
      it "creates the user role" do
        subject.call
        roles = Decidim::ConferenceUserRole.where(user:)

        expect(roles.count).to eq 1
        expect(roles.first.role).to eq "admin"
      end

      it "sends a notification to the user with the role assigned" do
        expect(Decidim::EventsManager).to receive(:publish).with(user_notification)

        subject.call
      end

      it "doesn't add admin privileges to the user" do
        subject.call
        user.reload

        expect(user).not_to be_admin
      end

      it "makes the new admin follow the process" do
        subject.call
        user.reload

        expect(user.follows?(my_conference)).to be true
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:perform_action!)
          .with(:create, Decidim::ConferenceUserRole, current_user, resource: hash_including(:title))
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)
        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
      end

      context "when there is no user with the given email" do
        let(:email) { "does_not_exist_conference@example.com" }

        it "creates a new user with said email" do
          subject.call
          expect(Decidim::User.last.email).to eq(email)
        end

        it "creates a new user with no application admin privileges" do
          subject.call
          expect(Decidim::User.last).not_to be_admin
        end
      end

      context "when a user and a role already exist" do
        before do
          subject.call
        end

        it "doesn't get created twice" do
          expect { subject.call }.to broadcast(:ok)

          roles = Decidim::ConferenceUserRole.where(user:)

          expect(roles.count).to eq 1
          expect(roles.first.role).to eq "admin"
        end
      end

      context "when the user hasn't accepted the invitation" do
        before do
          user.invite!
        end

        it "gets the invitation resent" do
          expect { subject.call }.to have_enqueued_job(ActionMailer::MailDeliveryJob)
        end
      end
    end
  end
end
