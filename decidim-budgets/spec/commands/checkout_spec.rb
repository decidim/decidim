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
    let(:budget) { create :budget, component: }

    let(:projects) { create_list(:project, 2, budget:, budget_amount: 45_000_000) }

    let(:order) do
      order = create(:order, user:, budget:)
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

      it "creates activelog entry" do
        expect(Decidim.traceability)
          .to receive(:update!)
          .with(order, order.user, { checked_out_at: be_within(10.seconds).of(Time.current) }, visibility: "private-only")
          .and_call_original

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
        let(:projects) { create_list(:project, 2, budget:, budget_amount: 30_000_000) }

        it "broadcasts invalid" do
          expect { subject.call }.to broadcast(:invalid)
        end
      end
    end

    context "when the voting rule is set to minimum projects number" do
      context "and the order doesn't reach the minimum number of projects" do
        let(:voting_rule) { :with_budget_projects_range }

        it "broadcasts invalid" do
          expect { subject.call }.to broadcast(:invalid)
        end
      end
    end

    context "when the voting rule is set to maximum projects number" do
      let(:component) do
        create(
          :budgets_component,
          voting_rule,
          vote_minimum_budget_projects_number:,
          organization: user.organization
        )
      end
      let(:voting_rule) { :with_budget_projects_range }
      let(:vote_minimum_budget_projects_number) { 0 }

      context "and the order exceed the maximum number of projects" do
        let(:projects) { create_list(:project, 8, budget:, budget_amount: 45_000_000) }

        it "broadcasts invalid" do
          expect { subject.call }.to broadcast(:invalid)
        end
      end

      context "when the total budget exceeds the maximum" do
        let(:projects) { create_list(:project, 4, budget:, budget_amount: 100_000_000) }

        it "broadcasts valid" do
          expect { subject.call }.to broadcast(:ok)
        end
      end
    end

    context "when the voting rule is set to minimum and maximum projects number" do
      let(:voting_rule) { :with_budget_projects_range }

      context "and the order exceed the maximum number of projects" do
        let(:projects) { create_list(:project, 8, budget:, budget_amount: 45_000_000) }

        it "broadcasts invalid" do
          expect { subject.call }.to broadcast(:invalid)
        end
      end

      context "and the order doesn't reach the minimum number of projects" do
        let(:projects) { create_list(:project, 2, budget:, budget_amount: 45_000_000) }

        it "broadcasts invalid" do
          expect { subject.call }.to broadcast(:invalid)
        end
      end

      context "when the total budget exceeds the maximum" do
        let(:projects) { create_list(:project, 4, budget:, budget_amount: 100_000_000) }

        it "broadcasts valid" do
          expect { subject.call }.to broadcast(:ok)
        end
      end
    end
  end
end
