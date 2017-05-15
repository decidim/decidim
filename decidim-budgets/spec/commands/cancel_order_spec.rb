# frozen_string_literal: true
require "spec_helper"

describe Decidim::Budgets::CancelOrder do
  let(:user) { create(:user) }
  let(:feature) do
    create(
      :budget_feature,
      :with_total_budget_and_vote_threshold_percent,
      organization: user.organization
    )
  end
  let(:project) { create(:project, feature: feature, budget: 90_000_000) }
  let(:order) do
    order = create(:order, user: user, feature: feature)
    order.projects << project
    order.checked_out_at = Time.zone.now
    order.save!
    order
  end

  subject { described_class.new(order) }

  context "when everything is ok" do
    it "broadcasts ok" do
      expect { subject.call }.to broadcast(:ok)
    end

    it "destroys the order" do
      subject.call
      expect(Decidim::Budgets::Order.count).to eq(0)
    end
  end

  context "when the order is not present" do
    let(:order) { nil }

    it "broadcasts invalid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end

  context "when the order is not checked out" do
    let(:order) { create(:order, user: user, feature: feature) }

    it "broadcasts invalid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end
end
