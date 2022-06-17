# frozen_string_literal: true

require "spec_helper"

describe Decidim::Metrics::UsersMetricManage do
  let(:organization) { create(:organization) }
  let(:day) { Time.zone.yesterday }
  let!(:users) { create_list(:user, 5, created_at: day, confirmed_at: nil, organization:) }
  let!(:other_user) { create(:user, created_at: day) }

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
      create(:metric, metric_type: "users", day:, cumulative: 1, quantity: 1, organization:)
      registry = generate_metric_registry.first

      expect(Decidim::Metric.count).to eq(1)
      expect(registry.cumulative).to eq(5)
      expect(registry.quantity).to eq(5)
    end
  end
end
