# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe ImpersonateUser do
    include ActiveSupport::Testing::TimeHelpers

    subject { described_class.new(form) }

    let(:organization) { create :organization }
    let(:current_user) { create :user, :admin, organization: }
    let(:document_number) { "12345678X" }
    let(:form_params) do
      {
        authorization: handler,
        user:
      }
    end
    let(:extra_params) do
      {
        reason: "Need it"
      }
    end
    let(:form) do
      ImpersonateUserForm.from_params(
        form_params.merge(extra_params)
      ).with_context(
        current_organization: organization,
        current_user:
      )
    end
    let(:handler) do
      DummyAuthorizationHandler.from_params(
        document_number:,
        user:
      )
    end

    shared_examples_for "the impersonate user command" do
      context "when everything is ok" do
        it "broadcasts ok" do
          expect { subject.call }.to broadcast(:ok)
        end

        it "creates a impersonation log" do
          expect do
            subject.call
          end.to change { Decidim::ImpersonationLog.count }.by(1)
        end

        it "creates a action log" do
          expect do
            subject.call
          end.to change { Decidim::ActionLog.count }.by(1)
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

    context "when logging action with reason" do
      let(:user) { create :user, organization: }

      it "creates a action log with reason" do
        expect do
          subject.call
        end.to change { Decidim::ActionLog.count }.by(1)

        expect(Decidim::ActionLog.last.action).to eq("manage")
      end
    end

    context "when passed a regular user" do
      let(:user) { create :user, organization: }

      it_behaves_like "the impersonate user command"
    end

    context "when passed an existing managed user" do
      let(:user) { create :user, :managed, organization: }

      it_behaves_like "the impersonate user command"
    end

    context "when passed a new managed user" do
      let(:user) { build :user, :managed, organization: }

      it_behaves_like "the impersonate user command"

      it "creates the user in DB" do
        expect { subject.call }.to change { Decidim::User.managed.count }.by(1)
      end
    end
  end
end
