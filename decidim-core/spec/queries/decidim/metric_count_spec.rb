# frozen_string_literal: true

require "spec_helper"

describe Decidim::MetricCount do
  let(:organization) { create(:organization) }
  let(:metric) { "random" }
  let!(:data) { create(:metric, day: Time.zone.today, cumulative: 5, quantity: 1, metric_type: metric, organization: organization) }

  context "when executing a count request" do
    it "returns the metric cumulative count" do
      result = described_class.for(organization, metric).count
      expect(result).to eq(5)
    end

    it "returns nothing for non present metric" do
      result = described_class.for(organization, "this-metric-does-not-exists").count
      expect(result).to eq(0)
    end
  end

  context "when executing a metric request" do
    it "returns the metric data" do
      result = described_class.for(organization, metric).metric
      expect(result.size).to eq(1)
      expect(result.first).to eq([Time.zone.today, 5])
    end

    it "returns nothing for non present metric" do
      result = described_class.for(organization, "this-metric-does-not-exists").metric
      expect(result.size).to eq(0)
    end
  end
end
