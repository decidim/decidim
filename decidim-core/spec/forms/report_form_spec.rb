# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ReportForm do
    subject { form }

    let(:reason) { "spam" }
    let(:params) do
      {
        reason:
      }
    end

    let(:form) do
      described_class.from_params(params)
    end

    context "when everything is OK" do
      it { is_expected.to be_valid }
    end

    context "when reason is not in the list" do
      let(:reason) { "foo" }

      it { is_expected.to be_invalid }
    end
  end
end
