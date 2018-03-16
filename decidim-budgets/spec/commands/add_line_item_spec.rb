# frozen_string_literal: true

require "spec_helper"

module Decidim::Budgets
  describe AddLineItem do
    subject { described_class.new(order, project, user) }

    let(:user) { create(:user) }
    let(:participatory_process) { create :participatory_process, :with_steps, organization: user.organization }
    let(:component) { create(:budget_component, participatory_space: participatory_process, settings: settings) }
    let(:project) { create(:project, component: component, budget: 60_000) }
    let(:settings) { { "total_budget" => 100_000, vote_threshold_percent: 50 } }
    let(:order) { nil }

    context "when everything is ok" do
      it "broadcasts ok" do
        expect { subject.call }.to broadcast(:ok)
      end

      context "when a order for the current user does exist" do
        let!(:order) { create(:order, user: user, component: component) }

        it "doesn't create a new order" do
          expect { subject.call }.not_to change(Order, :count)
        end
      end

      context "when a order for the current user doesn't exist" do
        it "creates an order" do
          expect { subject.call }.to change(Order, :count).by(1)
        end
      end

      it "adds a line item to the order" do
        subject.call
        last_order = Order.last
        expect(last_order.line_items.collect(&:project)).to eq([project])
      end
    end

    context "when the order is checked out" do
      let(:projects) do
        build_list(:project, 2, budget: 30_000, component: component)
      end

      let!(:order) do
        order = create(:order,
                       user: user,
                       component: component)
        order.projects << projects
        order.checked_out_at = Time.current
        order.save!
        order
      end

      it "broadcasts invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when the votes are not enabled" do
      let(:component) { create(:budget_component, :with_votes_disabled, participatory_space: participatory_process, settings: settings) }

      it "broadcasts invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end
  end
end
