# frozen_string_literal: true

require "spec_helper"
require "decidim/dev/test/authorization_shared_examples"

module Decidim
  describe DummyAuthorizationHandler do
    let(:handler) { described_class.new(params) }
    let(:params) { {} }

    it_behaves_like "an authorization handler"

    describe "metadata" do
      subject { handler.metadata }
      let(:params) { { document_number: "123456" } }

      it { is_expected.to eq(document_number: "123456") }
    end

    describe "valid?" do
      subject { handler.valid? }
      let(:params) { { document_number: document_number } }

      context "when no document number" do
        let(:document_number) { nil }

        it { is_expected.to eq(false) }
      end

      context "when document number is not valid" do
        let(:document_number) { "123456" }

        it { is_expected.to eq(false) }
      end

      context "when document number is valid" do
        let(:document_number) { "123456X" }

        it { is_expected.to eq(true) }
      end
    end
  end
end
