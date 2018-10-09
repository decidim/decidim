# frozen_string_literal: true

require "spec_helper"

describe Decidim::Metrics::UsersMetricManage do
  let(:organization) { create(:organization) }
  let(:day) { Time.zone.today - 1.day }
  let!(:users) { create_list(:user, 5, confirmed_at: day, organization: organization) }

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
      create(:metric, metric_type: "users", day: day, cumulative: 1, quantity: 1, organization: organization)
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
