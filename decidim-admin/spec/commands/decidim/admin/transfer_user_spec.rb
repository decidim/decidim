# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe TransferUser do
    include ActiveSupport::Testing::TimeHelpers

    subject { described_class.new(form) }

    let(:organization) { create :organization }
    let(:current_user) { create :user, organization: organization, email: email }
    let(:managed_user) { create :user, managed: true, organization: organization }
    let(:conflict) do
      Decidim::Verifications::Conflict.create(current_user: current_user, managed_user: managed_user)
    end
    let(:reason) { "Test reason" }
    let(:email) { "transfer@test.com" }

    let(:form_params) do
      {
        user: current_user,
        managed_user: managed_user,
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

    context "when user  is missing" do
      let(:current_user) {}

      it "broadcasts invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when solve conflict succeeds " do
      it "mark conflict as solved" do
        subject.call
        expect(conflict.reload.solved).to eq(true)
      end

      it "update email" do
        subject.call
        expect(managed_user.reload.unconfirmed_email).to eq(email)
      end
    end
  end
end
