# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::Metrics::AcceptedProposalsMetricManage do
  let(:organization) { create(:organization) }
  let(:participatory_space) { create(:participatory_process, :with_steps, organization:) }
  let(:component) { create(:proposal_component, :published, participatory_space:) }
  let(:day) { Time.zone.yesterday }
  let!(:accepted_proposals) { create_list(:proposal, 3, :accepted, created_at: day, component:) }
  let!(:not_accepted_proposals) { create_list(:proposal, 3, created_at: day, component:) }

  include_context "when managing metrics"

  context "when executing" do
    it "creates new metric records" do
      registry = generate_metric_registry

      expect(registry.collect(&:day)).to eq([day])
      expect(registry.collect(&:cumulative)).to eq([3])
      expect(registry.collect(&:quantity)).to eq([3])
    end

    it "does not create any record if there is no data" do
      registry = generate_metric_registry("2017-01-01")

      expect(Decidim::Metric.count).to eq(0)
      expect(registry).to be_empty
    end

    it "updates metric records" do
      create(:metric, metric_type: "accepted_proposals", day:, cumulative: 1, quantity: 1, organization:, category: nil, participatory_space:)
      registry = generate_metric_registry

      expect(Decidim::Metric.count).to eq(1)
      expect(registry.collect(&:cumulative)).to eq([3])
      expect(registry.collect(&:quantity)).to eq([3])
    end
  end
end
