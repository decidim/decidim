# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings
  describe Admin::InviteUserToJoinMeeting do
    subject { described_class.new(form, meeting, current_user) }

    let(:organization) { create :organization }
    let!(:current_user) { create :user, :admin, organization: organization }
    let(:name) { "name" }
    let(:email) { "foo@example.org" }
    let(:existing_user) { false }
    let(:user_id) { nil }
    let(:form_params) do
      {
        name: name,
        email: email,
        existing_user: existing_user,
        user_id: user_id
      }
    end
    let(:form) do
      Admin::MeetingRegistrationInviteForm.from_params(
        form_params
      ).with_context(
        current_organization: organization
      )
    end
    let!(:participatory_process) { create :participatory_process, organization: organization }
    let!(:component) { create :meeting_component, participatory_space: participatory_process }
    let!(:meeting) { create :meeting, component: component }

    context "when everything is ok" do
      before do
        clear_enqueued_jobs
      end

      shared_examples "creates the invitation and traces the action" do
        let(:invite) { Decidim::Meetings::Invite.last }

        it "creates the invitation" do
          expect do
            subject.call
          end.to change(Decidim::Meetings::Invite, :count).by(1)

          expect(invite.meeting).to eq(meeting)
          expect(invite.user).to eq(attendee)
        end

        it "traces the action", versioning: true do
          expect(Decidim.traceability)
            .to receive(:create!)
            .with(Decidim::Meetings::Invite, current_user, kind_of(Hash), hash_including(resource: hash_including(:title), participatory_space: hash_including(:title), attendee_name: attendee_name))
            .and_call_original

          expect { subject.call }.to change(Decidim::ActionLog, :count)
          action_log = Decidim::ActionLog.last
          expect(action_log.version).to be_present
        end
      end

      it "broadcasts ok" do
        expect { subject.call }.to broadcast(:ok)
      end

      context "when the form provides an existing user" do
        let!(:user) { create(:user, :confirmed, organization: organization) }
        let(:attendee_name) { user.name }
        let(:existing_user) { true }
        let(:user_id) { user.id }

        it "does not create another user" do
          expect do
            subject.call
          end.not_to change(Decidim::User, :count)
        end

        it_behaves_like "creates the invitation and traces the action" do
          let(:attendee) { user }
        end

        it "sends the invitation instructions" do
          subject.call
          expect(ActionMailer::MailDeliveryJob).to have_been_enqueued.on_queue("mailers")
        end
      end

      context "when a user already exists" do
        let!(:user) { create(:user, :confirmed, email: form.email, organization: organization) }
        let(:attendee_name) { user.name }

        it "does not create another user" do
          expect do
            subject.call
          end.not_to change(Decidim::User, :count)
        end

        it_behaves_like "creates the invitation and traces the action" do
          let(:attendee) { user }
        end

        it "sends the invitation instructions" do
          subject.call
          expect(ActionMailer::MailDeliveryJob).to have_been_enqueued.on_queue("mailers")
        end
      end

      context "when a user does not exist for the given email" do
        let(:attendee_name) { "name" }

        it "creates it" do
          expect do
            subject.call
          end.to change(Decidim::User, :count).by(1)

          expect(Decidim::User.last.email).to eq(form.email)
        end

        it "sends an invitation email with the given instructions" do
          subject.call

          queued_user, _, queued_options = ActiveJob::Arguments.deserialize(ActiveJob::Base.queue_adapter.enqueued_jobs.first[:args]).last[:args]

          expect(queued_user).to eq(Decidim::User.last)
          expect(queued_options).to eq(invitation_instructions: "join_meeting", meeting: meeting)
        end

        it_behaves_like "creates the invitation and traces the action" do
          let(:attendee) { Decidim::User.last }
        end
      end
    end

    context "when the form is not valid" do
      before do
        allow(form).to receive(:invalid?).and_return(true)
      end

      it "broadcasts invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when the user has already been invited" do
      before do
        meeting.invites << build(:invite, meeting: meeting, user: build(:user, email: email, organization: organization))
      end

      it "broadcasts invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end
  end
end
