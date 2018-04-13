# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe ImpersonateUser do
    include ActiveSupport::Testing::TimeHelpers

    subject { described_class.new(form) }

    let(:organization) { create :organization }
    let(:current_user) { create :user, :admin, organization: organization }
    let(:document_number) { "12345678X" }
    let(:form_params) do
      {
        authorization: handler,
        user: user
      }
    end
    let(:form) do
      ImpersonateUserForm.from_params(
        form_params
      ).with_context(
        current_organization: organization,
        current_user: current_user
      )
    end
    let(:user) { create :user, :managed, organization: organization }
    let(:handler) do
      Decidim::DummyAuthorizationHandler.from_params(
        document_number: document_number
      )
    end

    context "when everything is ok" do
      it "broadcasts ok" do
        expect { subject.call }.to broadcast(:ok)
      end

      it "creates a impersonation log" do
        expect do
          subject.call
        end.to change { Decidim::ImpersonationLog.count }.by(1)
      end

      it "expires the impersonation session automatically" do
        perform_enqueued_jobs { subject.call }
        travel Decidim::ImpersonationLog::SESSION_TIME_IN_MINUTES.minutes
        expect(Decidim::ImpersonationLog.last).to be_expired
      end
    end

    context "when the authorization is not valid" do
      let(:document_number) { "12345678Y" }

      it "is not valid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end
  end
end
