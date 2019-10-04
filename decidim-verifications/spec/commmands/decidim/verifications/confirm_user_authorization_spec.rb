# frozen_string_literal: true

require "spec_helper"

describe Decidim::Verifications::ConfirmUserAuthorization do
  subject { described_class.new(authorization, form) }

  let(:authorization) do
    create(
      :authorization,
      :pending,
      name: "cool_method",
      verification_metadata: verification_metadata
    )
  end

  let(:verification_metadata) do
    { secret_code: "XX42YY" }
  end

  let(:form_class) do
    Class.new(Decidim::Form) do
      mimic :authorization

      attribute :secret_code

      validates :secret_code, presence: true

      def verification_metadata
        { "secret_code" => secret_code }
      end
    end
  end

  let(:form) { form_class.new(secret_code: secret_code) }

  let(:authorizations) do
    Decidim::Verifications::Authorizations.new(organization: user.organization, user: user, granted: true)
  end

  let(:user) { authorization.user }

  context "when the form is not valid" do
    let(:secret_code) { nil }

    it "is not valid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end

  context "when the authorization is already confirmed" do
    let(:secret_code) { "XX42YY" }

    before { authorization.grant! }

    it "broadcasts already confirmed" do
      expect { subject.call }.to broadcast(:already_confirmed)
    end
  end

  context "when everything is ok" do
    let(:secret_code) { "XX42YY" }

    it "broadcasts ok" do
      expect { subject.call }.to broadcast(:ok)
    end

    it "confirms the authorization for the user" do
      expect { subject.call }.to change(authorizations, :count).by(1)
    end

    context "when there's a problem with the SMS service" do
      before do
        expect(authorization).to receive(:grant!).and_raise(StandardError, "Somewthing went wrong")
      end

      it "is not valid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end
  end
end
