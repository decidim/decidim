# frozen_string_literal: true

require "spec_helper"

describe Decidim::Admin::DashboardMetricChartsPresenter do
  subject { described_class.new(organization:, summary:, view_context: ActionController::Base.new.view_context) }

  let(:organization) { create :organization }
  let(:summary) { false }

  let(:summary_highlighted_metrics) { %w(users proposals) }
  let(:summary_highlighted_count) { summary_highlighted_metrics.count }

  let(:summary_not_highlighted_metrics) { %w(blocked_users user_reports reported_users comments accepted_proposals meetings results) }
  let(:summary_not_highlighted_count) { summary_not_highlighted_metrics.count }

  context "when not in summary mode" do
    describe "#highlighted_metrics" do
      it "shows all highlighted metrics" do
        expect(subject.highlighted_metrics.count).to be > summary_highlighted_count
      end
    end

    describe "#not_highlighted_metrics" do
      it "shows all not highlighted metrics" do
        expect(subject.not_highlighted_metrics.count).to be > summary_not_highlighted_count
      end
    end
  end

  context "when in summary mode" do
    let(:summary) { true }

    describe "#highlighted_metrics" do
      it "restrticts highlighted metrics" do
        expect(subject.highlighted_metrics.map(&:metric_name)).to eq(summary_highlighted_metrics)
      end
    end

    describe "#not_highlighted_metrics" do
      it "restrticts not highlighted metrics" do
        expect(subject.not_highlighted_metrics.map(&:metric_name)).to eq(summary_not_highlighted_metrics)
      end
    end
  end
end
