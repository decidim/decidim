# frozen_string_literal: true

require "spec_helper"
require "decidim/dev/test/authorization_shared_examples"

module Decidim
  describe DummyAuthorizationHandler do
    subject(:handler) { described_class.new(params) }

    let(:user) { create(:user, :confirmed) }
    let(:document_number) { "123456X" }
    let(:scope) { create :scope, organization: user.organization }
    let(:scope_id) { scope.id }
    let(:params) do
      {
        user:,
        document_number:,
        postal_code: "123456",
        scope_id:
      }
    end

    it_behaves_like "an authorization handler"

    it { is_expected.to be_valid }

    context "when no document number" do
      let(:document_number) { nil }

      it { is_expected.to be_invalid }
    end

    context "when document number is not valid" do
      let(:document_number) { "123456" }

      it { is_expected.to be_invalid }
    end

    context "when scope id is invalid" do
      let(:scope_id) { scope.id + 1 }

      it { is_expected.to be_invalid }
    end

    context "when scope is from other organization" do
      let(:scope) { create(:scope) }

      it { is_expected.to be_invalid }
    end

    describe "metadata" do
      subject { handler.metadata }

      it { is_expected.to eq(document_number: "123456X", postal_code: "123456", scope_id:) }
    end
  end
end
