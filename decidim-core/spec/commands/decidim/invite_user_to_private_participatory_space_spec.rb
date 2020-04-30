# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe InviteUserToPrivateParticipatorySpace do
    let(:command) { described_class.new(user, "invite_admin") }

    context "when the user was invited" do
      let(:user) { build(:user) }

      before do
        user.invite!
        clear_enqueued_jobs
      end

      it "sends the invitation instructions" do
        command.call
        expect(ActionMailer::DeliveryJob).to have_been_enqueued.on_queue("mailers")
      end

      it "broadcasts ok" do
        expect { command.call }.to broadcast(:ok)
      end

      it "regenerates the invitation token" do
        expect do
          command.call
        end.to change(user, :invitation_token)
      end

      it "regenerates the invitation due date" do
        expect do
          command.call
        end.to change(user, :invitation_due_at)
      end
    end

    context "when the user was not invited initially" do
      let!(:user) { create(:user) }

      before do
        clear_enqueued_jobs
      end

      it "sends the invitation instructions" do
        command.call
        expect(ActionMailer::DeliveryJob).to have_been_enqueued.on_queue("mailers")
      end

      it "broadcasts ok" do
        expect { command.call }.to broadcast(:ok)
      end
    end

    context "when the user has not accepted the invitation" do
      let(:user) { build(:user) }

      before do
        user.invite!
      end

      it "gets the invitation resent" do
        command.call
        expect(ActionMailer::DeliveryJob).to have_been_enqueued.on_queue("mailers").at_least(:once)
      end
    end

    context "when the user exists in the organization" do
      let!(:organization) { create :organization }
      let!(:user) { create :user, organization: organization }

      before do
        clear_enqueued_jobs
      end

      it "sends the invitation instructions" do
        command.call
        expect(ActionMailer::DeliveryJob).to have_been_enqueued.on_queue("mailers")
      end
    end

    context "when the user is a member of the private space already" do
      let!(:organization) { create :organization }
      let!(:private_participatory_space) { create(:participatory_process, organization: organization, private_space: true) }
      let!(:user) { create :user, organization: organization, invitation_accepted_at: DateTime.now }
      let!(:participatory_space_private_user) { create :participatory_space_private_user, user: user, privatable_to: private_participatory_space }

      before do
        clear_enqueued_jobs
      end

      it "does not send an email" do
        command.call
        expect(ActionMailer::DeliveryJob).not_to have_been_enqueued.on_queue("mailers")
      end

      it "broadcasts invalid" do
        expect { command.call }.to broadcast(:invalid)
      end
    end
  end
end
