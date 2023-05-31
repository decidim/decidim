# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe InviteUser do
    let(:organization) { create(:organization) }
    let!(:admin) { create(:user, :confirmed, :admin, organization:) }
    let(:form) do
      Decidim::InviteUserForm.from_params(
        name: "Old man",
        email: "oldman@email.com",
        organization:,
        role: "admin",
        invited_by: admin,
        invitation_instructions: "invite_admin"
      )
    end
    let!(:command) { described_class.new(form) }
    let(:invited_user) { User.where(organization:).last }

    context "when a user with the given email already exists in the same organization" do
      let!(:user) { create(:user, email: form.email, organization:) }

      it "does not create another user" do
        expect do
          command.call
        end.not_to change(User, :count)
      end

      it "broadcasts ok and the user" do
        expect do
          command.call
        end.to broadcast(:ok, user)
      end
    end

    context "when a user with the given email already exists in a different organization" do
      before do
        create(:user, :confirmed, email: form.email)
      end

      it "creates another user" do
        expect do
          command.call
        end.to change(User, :count).by(1)
      end

      it "broadcasts ok and the user" do
        expect do
          command.call
        end.to broadcast(:ok, an_instance_of(Decidim::User))
      end

      it "does not send the confirmation email" do
        clear_enqueued_jobs
        command.call

        jobs = ActiveJob::Base.queue_adapter.enqueued_jobs
        expect(jobs.count).to eq 1

        queued_user, _, queued_options = ActiveJob::Arguments.deserialize(jobs.first[:args]).last[:args]
        expect(queued_user).to eq(invited_user)
        expect(queued_options).to eq(invitation_instructions: "invite_admin")
      end
    end

    it "adds the roles for the user" do
      command.call

      expect(invited_user).to be_admin
    end

    context "when a user does not exist for the given email" do
      it "creates it" do
        expect do
          command.call
        end.to change(User, :count).by(1)

        expect(invited_user.email).to eq(form.email)
      end

      it "broadcasts ok and the user" do
        expect do
          command.call
        end.to broadcast(:ok)
      end

      it "sends an invitation email with the given instructions" do
        clear_enqueued_jobs
        command.call

        queued_user, _, queued_options = ActiveJob::Arguments.deserialize(ActiveJob::Base.queue_adapter.enqueued_jobs.first[:args]).last[:args]

        expect(queued_user).to eq(invited_user)
        expect(queued_options).to eq(invitation_instructions: "invite_admin")
      end
    end
  end
end
