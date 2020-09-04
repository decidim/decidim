# frozen_string_literal: true

require "spec_helper"

module Decidim::Budgets
  describe Checkout do
    subject { described_class.new(current_order) }

    let(:user) { create(:user) }
    let(:voting_rule) { :with_vote_threshold_percent }
    let(:component) do
      create(
        :budgets_component,
        voting_rule,
        organization: user.organization
      )
    end
    let(:budget) { create :budget, component: component }

    let(:projects) { create_list(:project, 2, budget: budget, budget_amount: 45_000_000) }

    let(:order) do
      order = create(:order, user: user, budget: budget)
      order.projects << projects
      order.save!
      order
    end

    let(:current_order) { order }

    context "when everything is ok" do
      it "broadcasts ok" do
        expect { subject.call }.to broadcast(:ok)
      end

      it "sets the checked out at" do
        subject.call
        order.reload
        expect(order.checked_out_at).not_to be_nil
      end

      it "schedules a job to send an email with the summary" do
        expect(SendOrderSummaryJob).to receive(:perform_later).with(order)

        subject.call
      end
    end

    context "when the order is not present" do
      let(:current_order) { nil }

      it "broadcasts invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when the voting rule is set to threshold percent" do
      context "when the order total budget doesn't exceed the threshold" do
        let(:projects) { create_list(:project, 2, budget: budget, budget_amount: 30_000_000) }

        it "broadcasts invalid" do
          expect { subject.call }.to broadcast(:invalid)
        end
      end
    end

    context "when the voting rule is set to minimum projects number" do
      context "and the order doesn't reach the minimum number of projects" do
        let(:voting_rule) { :with_minimum_budget_projects }

        it "broadcasts invalid" do
          expect { subject.call }.to broadcast(:invalid)
        end
      end
    end
  end
end
