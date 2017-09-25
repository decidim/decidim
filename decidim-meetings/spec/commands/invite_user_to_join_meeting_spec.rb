# frozen_string_literal: true

require "spec_helper"

describe Decidim::Meetings::Admin::InviteUserToJoinMeeting do
  let(:organization) { create :organization }
  let!(:current_user) { create :user, :admin, organization: organization }
  let(:name) { "name" }
  let(:email) { "foo@example.org" }
  let(:form_params) do
    {
      name: name,
      email: email
    }
  end
  let(:form) do
    Decidim::Meetings::Admin::MeetingRegistrationInviteForm.from_params(
      form_params
    ).with_context(
      current_organization: organization
    )
  end
  let!(:participatory_process) { create :participatory_process, organization: organization }
  let!(:feature) { create :meeting_feature, participatory_space: participatory_process }
  let!(:meeting) { create :meeting, feature: feature }

  # around do |example|
  #   perform_enqueued_jobs do
  #     example.run
  #   end
  # end

  subject { described_class.new(form, meeting, current_user) }

  context "when everything is ok" do
    before do
      clear_enqueued_jobs
    end

    it "broadcasts ok" do
      expect { subject.call }.to broadcast(:ok)
    end

    context "when a user already exists" do
      let!(:user) { create(:user, :confirmed, email: form.email, organization: organization) }

      it "does not create another user" do
        expect do
          subject.call
        end.not_to change { Decidim::User.count }
      end

      it "sends the invitation instructions" do
        subject.call
        expect(ActionMailer::DeliveryJob).to have_been_enqueued.on_queue("mailers")
      end
    end

    context "when a user does not exist for the given email" do
      it "creates it" do
        expect do
          subject.call
        end.to change { Decidim::User.count }.by(1)

        expect(Decidim::User.last.email).to eq(form.email)
      end

      it "sends an invitation email with the given instructions" do
        subject.call

        _, _, _, queued_user, _, queued_options = ActiveJob::Arguments.deserialize(ActiveJob::Base.queue_adapter.enqueued_jobs.first[:args])

        expect(queued_user).to eq(Decidim::User.last)
        expect(queued_options).to eq(invitation_instructions: "join_meeting", meeting: meeting)
      end
    end
  end

  context "when the form is not valid" do
    before do
      expect(form).to receive(:invalid?).and_return(true)
    end

    it "broadcasts invalid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end
end
