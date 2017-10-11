# frozen_string_literal: true

require "spec_helper"

describe Decidim::Verifications::PartiallyAuthorizeUser do
  subject { described_class.new(form) }

  let(:verification_metadata) do
    { secret_code: "XX42YY" }
  end

  let(:form_class) do
    Class.new(Decidim::AuthorizationHandler) do
      mimic :address

      attribute :address, String

      validates :address, presence: true

      def handler_name
        "postal_address"
      end

      def verification_metadata
        { address: address, sms_code: rand(10_000) }
      end
    end
  end

  let(:authorizations) do
    Decidim::Authorizations.new(user: user, granted: false)
  end

  let(:user) { create(:user) }

  let(:form) { form_class.new(user: user, address: address) }

  context "when the form is not valid" do
    let(:address) { nil }

    it "is not valid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end

  context "when the form is valid" do
    let(:address) { "C/ Perry" }

    it "broadcasts already confirmed" do
      expect { subject.call }.to broadcast(:ok)
    end

    it "creates a pending authorization for the user" do
      expect { subject.call }.to change { authorizations.count }.by(1)
    end
  end
end
