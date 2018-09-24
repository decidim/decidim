# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::Metrics::ProposalsMetricManage do
  let(:organization) { create(:organization) }
  let(:participatory_space) { create(:participatory_process, :with_steps, organization: organization) }
  let(:component) { create(:proposal_component, :published, participatory_space: participatory_space) }
  let(:day) { Time.zone.today - 1.day }
  let!(:proposals) { create_list(:proposal, 5, published_at: day, component: component) }

  context "when executing" do
    it "creates new metric records" do
      registry = generate_metric_registry

      expect(registry.collect(&:day)).to eq([day])
      expect(registry.collect(&:cumulative)).to eq([5])
      expect(registry.collect(&:quantity)).to eq([5])
    end

    it "does not create any record if there is no data" do
      registry = generate_metric_registry("2017-01-01")

      expect(Decidim::Metric.count).to eq(0)
      expect(registry).to be_empty
    end

    it "updates metric records" do
      create(:metric, metric_type: "proposals", day: day, cumulative: 1, quantity: 1, organization: organization, category: nil, participatory_space: participatory_space)
      registry = generate_metric_registry

      expect(Decidim::Metric.count).to eq(1)
      expect(registry.collect(&:cumulative)).to eq([5])
      expect(registry.collect(&:quantity)).to eq([5])
    end
  end
end

def generate_metric_registry(date = nil)
  metric = described_class.for(date, organization)
  metric.save
end
