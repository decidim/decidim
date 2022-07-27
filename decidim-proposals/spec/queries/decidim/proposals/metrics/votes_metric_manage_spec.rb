# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::Metrics::VotesMetricManage do
  let(:organization) { create(:organization) }
  let(:participatory_space) { create(:participatory_process, :with_steps, organization:) }
  let(:component) { create(:proposal_component, :published, participatory_space:) }
  let(:proposal) { create(:proposal, component:) }
  let(:day) { Time.zone.yesterday }
  let!(:votes) { create_list(:proposal_vote, 5, proposal:, created_at: day) }

  include_context "when managing metrics"

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
      create(:metric, metric_type: "votes", day:, cumulative: 1, quantity: 1, organization:, category: nil, participatory_space:, related_object: proposal)
      registry = generate_metric_registry

      expect(Decidim::Metric.count).to eq(1)
      expect(registry.collect(&:cumulative)).to eq([5])
      expect(registry.collect(&:quantity)).to eq([5])
    end

    context "when calculating the metrics" do
      let(:withdrawn_proposal) { create(:proposal, state: "withdrawn", component:) }
      let!(:invalid_votes) { create_list(:proposal_vote, 5, proposal: withdrawn_proposal, created_at: day) }
      let(:moderation) { create(:moderation, reportable: proposal, report_count: 1, participatory_space:) }
      let!(:report) { create(:report, moderation:) }

      it "filters the data correctly" do
        proposal.moderation.update!(hidden_at: Time.current)

        registry = generate_metric_registry

        expect(registry.collect(&:cumulative)).to eq([])
        expect(registry.collect(&:quantity)).to eq([])
      end
    end
  end
end
