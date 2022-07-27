# frozen_string_literal: true

require "spec_helper"

module Decidim::Votings
  describe SendAccessCode do
    subject { described_class.new(datum, medium) }

    let(:voting) { create(:voting) }
    let(:datum) { create(:datum, :with_access_code, dataset:) }
    let(:mobile_phone_number) { datum.mobile_phone_number }
    let(:access_code) { datum.access_code }
    let(:dataset) { create(:dataset, voting:) }
    let(:medium) { "email" }

    context "when datum is nil" do
      let(:datum) { nil }

      it "broadcasts invalid" do
        expect(subject.call).to broadcast(:invalid)
      end
    end

    describe "when the datum is given" do
      let(:mailer) { double(:mailer) }

      context "when medium is email" do
        it "sends an email" do
          allow(Decidim::Votings::AccessCodeMailer)
            .to receive(:send_access_code)
            .with(datum)
            .and_return(mailer)
          expect(mailer)
            .to receive(:deliver_later)

          subject.call
        end
      end

      context "when medium is sms" do
        let(:medium) { "sms" }

        it "does not send an email" do
          expect(Decidim::Votings::AccessCodeMailer).not_to receive(:send_access_code)
          subject.call
        end

        it "sends a SMS" do
          expect(Decidim::Verifications::Sms::ExampleGateway)
            .to(receive(:new).with(mobile_phone_number, access_code))
            .and_return(double(deliver_code: true))
          subject.call
        end
      end

      context "when medium missing" do
        let(:medium) { "" }

        it "does not send an email or sms and raises an error" do
          expect(Decidim::Votings::AccessCodeMailer).not_to receive(:send_access_code)
          expect(Decidim::Verifications::Sms::ExampleGateway).not_to(receive(:new).with(mobile_phone_number, access_code))

          expect { subject.call }.to raise_error(ArgumentError)
        end
      end
    end
  end
end
