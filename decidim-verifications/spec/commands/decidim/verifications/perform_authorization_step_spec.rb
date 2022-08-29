# frozen_string_literal: true

require "spec_helper"

describe Decidim::Verifications::PerformAuthorizationStep do
  subject { described_class.new(authorization, form) }

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
        { address:, sms_code: rand(10_000) }
      end
    end
  end

  let(:authorizations) do
    Decidim::Verifications::Authorizations.new(organization: user.organization, user:, granted: false)
  end

  let(:user) { create(:user, :confirmed) }

  let(:form) { form_class.new(user:, address:) }

  let(:authorization_params) do
    {
      user:,
      name: "postal_address",
      verification_metadata: { phone_number: "666666666", sms_code: "10_001" }
    }
  end

  context "when authorization is already is DB" do
    let(:authorization) do
      create(:authorization, :pending, authorization_params)
    end

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

      it "updates the pending authorization for the user" do
        expect { subject.call }.to change(authorizations, :count).by(1)
      end
    end
  end

  context "when authorization is not yet saved to DB" do
    let(:authorization) do
      build(:authorization, :pending, authorization_params)
    end

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
        expect { subject.call }.to change(authorizations, :count).by(1)
      end

      it "overwrites the new verification information" do
        subject.call

        verification_metadata = authorizations.first.verification_metadata

        expect(verification_metadata["sms_code"].to_i).to be < 10_000
      end
    end
  end
end
