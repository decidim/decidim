# frozen_string_literal: true
require "spec_helper"

module Decidim
  module Proposals
    describe ProposalReportForm do
      let(:type) { "spam" }
      let(:params) do
        {
          type: type
        }
      end

      let(:form) do
        described_class.from_params(params)
      end

      subject { form }

      context "when everything is OK" do
        it { is_expected.to be_valid }
      end

      context "when type is not in the list" do
        let(:type) { "foo" }
        it { is_expected.to be_invalid }
      end
    end
  end
end