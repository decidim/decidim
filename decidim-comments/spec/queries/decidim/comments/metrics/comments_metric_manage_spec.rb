# frozen_string_literal: true

require "spec_helper"

describe Decidim::Comments::Metrics::CommentsMetricManage do
  let(:organization) { create(:organization) }
  let(:participatory_process) { create(:participatory_process, organization:) }
  let(:component) { create(:component, participatory_space: participatory_process) }
  let(:commentable) { create(:dummy_resource, component:) }
  let(:author) { create(:user, organization:) }
  let(:day) { Time.zone.yesterday }
  let!(:comments) { create_list(:comment, 5, created_at: day, author:, commentable:) }
  let!(:old_comments) { create_list(:comment, 5, created_at: day - 1.week, author:, commentable:) }

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
      create(:metric, metric_type: "comments", day:, cumulative: 1, quantity: 1, organization:, related_object: commentable, category: nil, participatory_space: participatory_process)
      registry = generate_metric_registry

      expect(Decidim::Metric.count).to eq(1)
      expect(registry.collect(&:cumulative)).to eq([10])
      expect(registry.collect(&:quantity)).to eq([5])
    end
  end
end
