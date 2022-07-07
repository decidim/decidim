# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe TransferUser do
    include ActiveSupport::Testing::TimeHelpers

    subject { described_class.new(form) }

    let(:organization) { create :organization }
    let(:current_user) { create :user, :admin, organization: organization }
    let(:new_user) { create :user, :admin, organization: organization, email: email, confirmed_at: Time.now.utc }
    let(:managed_user) { create :user, managed: true, organization: organization }
    let(:conflict) do
      Decidim::Verifications::Conflict.create(current_user: new_user, managed_user: managed_user)
    end
    let(:reason) { "Test reason" }
    let(:email) { "transfer@test.com" }

    let(:form_params) do
      {
        current_user: current_user,
        reason: reason,
        email: email,
        conflict: conflict
      }
    end

    let(:form) do
      TransferUserForm.from_params(
        form_params
      ).with_context(
        current_organization: organization,
        current_user: current_user
      )
    end

    context "when everything is ok" do
      it "broadcasts ok" do
        expect { subject.call }.to broadcast(:ok)
      end
    end

    context "when user is missing" do
      let(:current_user) { nil }

      it "broadcasts invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when solve conflict succeeds" do
      it "mark conflict as solved" do
        subject.call
        expect(conflict.reload.solved).to be(true)
      end

      it "update email" do
        subject.call
        expect(managed_user.reload.email).to eq(email)
      end

      it "update managed_user password" do
        subject.call
        expect(new_user.encrypted_password).to eq(managed_user.reload.encrypted_password)
      end

      it "update confirmed at" do
        subject.call
        expect(managed_user.reload.confirmed_at).not_to be_nil
      end

      it "update managed to false" do
        subject.call
        expect(managed_user.reload.managed).to be(false)
      end

      it "log transfer action" do
        expect { subject.call }.to change(Decidim::ActionLog, :count).by(1)
        log = Decidim::ActionLog.last

        expect(log.resource).to eq(managed_user)
        expect(log.user).to eq(current_user)
      end
    end
  end
end
