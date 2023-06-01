# frozen_string_literal: true

require "spec_helper"

describe Decidim::Metrics::UsersMetricManage do
  let(:organization) { create(:organization) }
  let(:day) { Time.zone.yesterday }
  let!(:users) { create_list(:user, 5, :confirmed, created_at: day, organization:) }
  let!(:other_user) { create(:user, :confirmed, created_at: day) }
  let!(:unconfirmed_user) { create(:user, created_at: day, organization:) }

  include_context "when managing metrics"

  context "when executing" do
    shared_examples "computes the metric" do
      it "creates new metric records" do
        registry = generate_metric_registry.first

        expect(registry.day).to eq(day)
        expect(registry.cumulative).to eq(5)
        expect(registry.quantity).to eq(5)
      end
    end

    include_examples "computes the metric"

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

    context "when removing deleted users from query" do
      context "when the user is deleted long before the end_time" do
        let!(:deleted_user) { create(:user, :confirmed, created_at: day, deleted_at: day - 1.month, organization:) }

        include_examples "computes the metric"
      end

      context "when the user is deleted before the end_time" do
        let!(:deleted_user) { create(:user, :confirmed, created_at: day, deleted_at: day, organization:) }

        include_examples "computes the metric"
      end

      context "when the user is deleted after the end_time" do
        let!(:deleted_user) { create(:user, :confirmed, created_at: day, deleted_at: day + 1.month, organization:) }

        it "does not count them" do
          registry = generate_metric_registry.first

          expect(Decidim::Metric.count).to eq(1)
          expect(registry.cumulative).to eq(6)
          expect(registry.quantity).to eq(6)
        end
      end
    end

    context "when removing blocked users from query" do
      context "when the user is blocked long before the end_time" do
        let!(:deleted_user) { create(:user, :confirmed, created_at: day, blocked_at: day - 1.month, organization:) }

        include_examples "computes the metric"
      end

      context "when the user is blocked before the end_time" do
        let!(:deleted_user) { create(:user, :confirmed, created_at: day, blocked_at: day, organization:) }

        include_examples "computes the metric"
      end

      context "when the user is blocked after the end_time" do
        let!(:deleted_user) { create(:user, :confirmed, created_at: day, blocked_at: day + 1.month, organization:) }

        it "does not count them" do
          registry = generate_metric_registry.first

          expect(Decidim::Metric.count).to eq(1)
          expect(registry.cumulative).to eq(6)
          expect(registry.quantity).to eq(6)
        end
      end
    end
  end
end
