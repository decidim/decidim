# frozen_string_literal: true
require "spec_helper"

module Decidim
  module Proposals
    describe ProposalReportForm do
      let(:reason) { "spam" }
      let(:params) do
        {
          reason: reason
        }
      end

      let(:form) do
        described_class.from_params(params)
      end

      subject { form }

      context "when everything is OK" do
        it { is_expected.to be_valid }
      end

      context "when reason is not in the list" do
        let(:reason) { "foo" }
        it { is_expected.to be_invalid }
      end
    end
  end
end