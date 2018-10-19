# frozen_string_literal: true

require "spec_helper"

describe Decidim::Assemblies::Metrics::AssembliesMetricManage do
  let(:organization) { create(:organization) }
  let(:day) { Time.zone.today - 1.day }
  let!(:assemblies) { create_list(:assembly, 5, organization: organization, published_at: day) }

  context "when executing" do
    it "creates new metric records" do
      registry = generate_metric_registry

      expect(registry.day).to eq(day)
      expect(registry.cumulative).to eq(5)
      expect(registry.quantity).to eq(5)
    end

    it "does not create any record if there is no data" do
      registry = generate_metric_registry("2017-01-01")

      expect(Decidim::Metric.count).to eq(0)
      expect(registry).to be_nil
    end

    it "updates metric records" do
      create(:metric, metric_type: "assemblies", day: day, cumulative: 1, quantity: 1, organization: organization, category: nil)
      registry = generate_metric_registry

      expect(Decidim::Metric.count).to eq(1)
      expect(registry.cumulative).to eq(5)
      expect(registry.quantity).to eq(5)
    end
  end
end

def generate_metric_registry(date = nil)
  metric = described_class.for(date, organization)
  metric.save
end
