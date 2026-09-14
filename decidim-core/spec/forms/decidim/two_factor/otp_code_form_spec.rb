# frozen_string_literal: true

require "spec_helper"

module Decidim
  module TwoFactor
    describe OtpCodeForm do
      subject { described_class.from_params(code:) }

      let(:code) { "123456" }

      it { is_expected.to be_valid }

      context "when the code carries spaces" do
        let(:code) { " 123 456 " }

        it "is valid and normalized" do
          expect(subject).to be_valid
          expect(subject.code).to eq("123456")
        end
      end

      context "when the code is not six digits" do
        let(:code) { "12345" }

        it { is_expected.not_to be_valid }
      end
    end
  end
end
