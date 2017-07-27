# frozen_string_literal: true

require "spec_helper"

describe Decidim::Admin::ImpersonateManagedUser do
  include ActiveSupport::Testing::TimeHelpers

  let(:organization) { create :organization }
  let(:current_user) { create :user, :admin, organization: organization }
  let(:document_number) { "12345678X" }
  let(:form_params) do
    {
      authorization: {
        handler_name: "Decidim::DummyAuthorizationHandler",
        document_number: document_number
      }
    }
  end
  let(:form) do
    Decidim::Admin::ImpersonateManagedUserForm.from_params(
      form_params
    ).with_context(
      current_organization: organization
    )
  end
  let(:user) { create :user, :managed, organization: organization }
  let(:handler_document_number) { document_number }
  let(:handler) do
    Decidim::DummyAuthorizationHandler.from_params(
      document_number: handler_document_number
    )
  end
  let!(:authorization) do
    create(:authorization,
           user: user,
           name: handler.handler_name,
           attributes: { unique_id: handler.unique_id })
  end

  subject { described_class.new(form, user, current_user) }

  context "when everything is ok" do
    it "broadcasts ok" do
      expect { subject.call }.to broadcast(:ok)
    end

    it "creates a impersonation log" do
      expect do
        subject.call
      end.to change { Decidim::ImpersonationLog.count }.by(1)
    end

    it "expires the impersonation session automatically", perform_enqueued: true do
      subject.call
      travel Decidim::ImpersonationLog::SESSION_TIME
      expect(Decidim::ImpersonationLog.last).to be_expired
    end
  end

  context "when the user is not managed" do
    let(:user) { create :user }

    it "is not valid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end

  context "when the authorization is not valid" do
    let(:handler_document_number) { "98765432X" }

    it "is not valid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end
end
