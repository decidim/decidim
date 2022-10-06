# frozen_string_literal: true

require "spec_helper"

module Decidim::Verifications::Sms
  describe MobilePhoneForm do
    subject do
      described_class.new(
        mobile_phone_number:,
        user:
      )
    end

    let(:mobile_phone_number) { "600102030" }
    let(:user) { create(:user, :confirmed) }

    context "when everything is OK" do
      it { is_expected.to be_valid }

      describe "verification metadata" do
        it "includes the verification code" do
          expect(subject.verification_metadata).to include(verification_code: kind_of(String))
        end
      end

      it "sets phone number as the unique_id" do
        other_user = create(:user, organization: user.organization)
        create(:authorization, name: "sms", user: other_user, unique_id: subject.unique_id)

        expect(subject).to be_invalid
        expect(subject.errors[:base]).to eq(["A participant is already authorized with the same data. An administrator will contact you to verify your details."])
      end
    end

    describe "validations" do
      context "without a phone number" do
        let(:mobile_phone_number) { nil }

        it { is_expected.to be_invalid }
      end

      context "without a sms gateway" do
        before do
          Decidim.sms_gateway_service = "FooBar"
        end

        after do
          Decidim.sms_gateway_service = "Decidim::Verifications::Sms::ExampleGateway"
        end

        it { is_expected.to be_invalid }
      end

      context "when the code delivery fails" do
        before do
          allow(Decidim::Verifications::Sms::ExampleGateway)
            .to(receive(:new).with(mobile_phone_number, kind_of(String)))
            .and_return(double(deliver_code: nil))
        end

        it { is_expected.to be_invalid }
      end
    end

    describe "mobile_phone_number" do
      let(:mobile_phone_number) { "+34 600-10.20 30" }

      it "only allows numbers and the + symbol" do
        expect(subject.mobile_phone_number).to eq("+34600102030")
      end
    end
  end
end
