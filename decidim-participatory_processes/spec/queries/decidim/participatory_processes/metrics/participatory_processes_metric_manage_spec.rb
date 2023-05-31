# frozen_string_literal: true

require "spec_helper"

describe Decidim::ParticipatoryProcesses::Metrics::ParticipatoryProcessesMetricManage do
  let(:organization) { create(:organization) }
  let(:day) { Time.zone.yesterday }
  let!(:participatory_processes) { create_list(:participatory_process, 5, organization:, published_at: day) }

  include_context "when managing metrics"

  context "when executing" do
    it "creates new metric records" do
      registry = generate_metric_registry.first

      expect(registry.day).to eq(day)
      expect(registry.cumulative).to eq(5)
      expect(registry.quantity).to eq(5)
    end

    it "does not create any record if there is no data" do
      registry = generate_metric_registry("2017-01-01")

      expect(Decidim::Metric.count).to eq(0)
      expect(registry).to be_empty
    end

    it "updates metric records" do
      create(:metric, metric_type: "participatory_processes", day:, cumulative: 1, quantity: 1, organization:, category: nil)
      registry = generate_metric_registry.first

      expect(Decidim::Metric.count).to eq(1)
      expect(registry.cumulative).to eq(5)
      expect(registry.quantity).to eq(5)
    end
  end
end
