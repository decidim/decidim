# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::Metrics::EndorsementsMetricManage do
  let(:organization) { create(:organization) }
  let(:participatory_space) { create(:participatory_process, :with_steps, organization:) }
  let(:component) { create(:proposal_component, :published, participatory_space:) }
  let(:proposal) { create(:proposal, component:) }
  let(:day) { Time.zone.today - 1.day }
  let!(:endorsements) do
    5.times.collect do
      create(:endorsement, resource: proposal, created_at: day, author: build(:user, organization: proposal.organization))
    end
  end
  let!(:old_endorsements) do
    5.times.collect do
      create(:endorsement, resource: proposal, created_at: (day - 1.week), author: build(:user, organization: proposal.organization))
    end
  end

  include_context "when managing metrics"

  context "when executing" do
    it "creates new metric records" do
      registry = generate_metric_registry

      expect(registry.collect(&:day)).to eq([day])
      expect(registry.collect(&:cumulative)).to eq([10])
      expect(registry.collect(&:quantity)).to eq([5])
    end

    it "does not create any record if there is no data" do
      registry = generate_metric_registry("2017-01-01")

      expect(Decidim::Metric.count).to eq(0)
      expect(registry).to be_empty
    end

    it "updates metric records" do
      create(:metric, metric_type: "endorsements", day:, cumulative: 1, quantity: 1, organization:, category: nil, participatory_space:, related_object: proposal)
      registry = generate_metric_registry

      expect(Decidim::Metric.count).to eq(1)
      expect(registry.collect(&:cumulative)).to eq([10])
      expect(registry.collect(&:quantity)).to eq([5])
    end
  end
end
