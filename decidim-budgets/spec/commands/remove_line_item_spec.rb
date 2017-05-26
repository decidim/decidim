# frozen_string_literal: true

require "spec_helper"

describe Decidim::Budgets::RemoveLineItem do
  let(:user) { create(:user) }
  let(:feature) do
    create(:budget_feature,
           organization: user.organization,
           settings: { "total_budget" => 100_000, "vote_threshold_percent": 50 })
  end
  let(:project) { create(:project, feature: feature, budget: 100) }

  let(:order) do
    order = create(:order, user: user, feature: feature)
    order.projects << project
    order.save!
    order
  end

  subject { described_class.new(order, project) }

  context "when everything is ok" do
    it "broadcasts ok" do
      expect { subject.call }.to broadcast(:ok)
    end

    it "removes a line item from the order" do
      subject.call
      last_order = Decidim::Budgets::Order.last
      expect(last_order.line_items.collect(&:project)).to be_empty
    end
  end

  context "when the order is checked out" do
    before do
      order.update_attribute :checked_out_at, Time.current
    end

    it "broadcasts invalid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end
end
