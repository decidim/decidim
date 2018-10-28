# frozen_string_literal: true

require "spec_helper"

module Decidim::Budgets
  describe CancelOrder do
    subject { described_class.new(order) }

    let(:user) { create(:user) }
    let(:component) do
      create(
        :budget_component,
        :with_total_budget_and_vote_threshold_percent,
        organization: user.organization
      )
    end
    let(:project) { create(:project, component: component, budget: 90_000_000) }
    let(:order) do
      order = create(:order, user: user, component: component)
      order.projects << project
      order.checked_out_at = Time.current
      order.save!
      order
    end

    context "when everything is ok" do
      it "broadcasts ok" do
        expect { subject.call }.to broadcast(:ok)
      end

      it "destroys the order" do
        subject.call
        expect(Order.count).to eq(0)
      end
    end

    context "when the order is not present" do
      let(:order) { nil }

      it "broadcasts invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when the order is not checked out" do
      let(:order) { create(:order, user: user, component: component) }

      it "broadcasts invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end
  end
end
