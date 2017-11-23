# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe InviteUserAgain do
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
    end

    context "when the user was not invited initially" do
      let!(:user) { create(:user) }

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
