# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe MetricOperationManifest do
    subject do
      described_class.new(
        metric_name:,
        manager_class:,
        metric_operation:
      )
    end

    let(:metric_name) do
      :dummy_resources
    end

    let(:manager_class) do
      "DummyResources::DummyResource"
    end

    let(:metric_operation) do
      :dummy_operation
    end

    context "when no metric_name is set" do
      let(:metric_name) { nil }

      it { is_expected.to be_invalid }
    end

    context "when no manager_class is set" do
      let(:manager_class) { nil }

      it { is_expected.to be_invalid }
    end

    context "when no metric_operation is set" do
      let(:metric_operation) { nil }

      it { is_expected.to be_invalid }
    end
  end
end
