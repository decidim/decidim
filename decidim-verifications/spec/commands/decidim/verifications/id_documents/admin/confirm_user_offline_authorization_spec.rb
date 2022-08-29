# frozen_string_literal: true

require "spec_helper"

describe Decidim::Verifications::IdDocuments::Admin::ConfirmUserOfflineAuthorization do
  subject { described_class.new(form) }

  let(:authorization) do
    create(
      :authorization,
      :pending,
      name: "id_documents",
      verification_metadata:
    )
  end

  let(:verification_type) { "offline" }
  let(:verification_metadata) do
    { secret_code: "XX42YY", verification_type: }
  end

  let(:form_class) do
    Class.new(Decidim::Form) do
      mimic :authorization

      attribute :email
      attribute :secret_code

      validates :secret_code, presence: true

      def verification_metadata
        { "secret_code" => secret_code }
      end
    end
  end

  let(:email) { user.email }
  let(:form) do
    form_class.new(
      secret_code:,
      email:
    ).with_context(
      current_user: admin,
      current_organization: user.organization
    )
  end

  let(:granted_authorizations) do
    Decidim::Verifications::Authorizations.new(organization: user.organization, user:, granted: true)
  end

  let(:user) { authorization.user }
  let(:admin) { create :user, :admin, organization: user.organization }

  context "when the form is not valid" do
    let(:secret_code) { nil }

    it "is not valid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end

  context "when the authorization is not found" do
    let(:email) { "this@doesnt.exist" }
    let(:secret_code) { "XX42YY" }

    it "broadcasts invalid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end

  context "when the authorization is not offline" do
    let(:verification_type) { :online }
    let(:secret_code) { "XX42YY" }

    it "broadcasts invalid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end

  context "when the authorization is already confirmed" do
    let(:secret_code) { "XX42YY" }

    before { authorization.grant! }

    it "broadcasts already confirmed" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end

  context "when everything is ok" do
    let(:secret_code) { "XX42YY" }

    it "broadcasts ok" do
      expect { subject.call }.to broadcast(:ok)
    end

    it "confirms the authorization for the user" do
      expect { subject.call }.to change(granted_authorizations, :count).by(1)
    end

    it "traces the action", versioning: true do
      expect(Decidim.traceability)
        .to receive(:perform_action!)
        .with(:grant_id_documents_offline_verification, user, admin)
        .and_call_original
      expect { subject.call }.to change(Decidim::ActionLog, :count)
      action_log = Decidim::ActionLog.last
      expect(action_log.version).to be_present
    end
  end
end
