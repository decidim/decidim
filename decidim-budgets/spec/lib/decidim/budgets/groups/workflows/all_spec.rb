# frozen_string_literal: true

require "spec_helper"

module Decidim::Budgets::Groups
  describe Workflows::All do
    subject(:workflow) { described_class.new(budgets_group, current_user) }

    let(:budgets_group) { create(:budgets_group_component, :with_children) }
    let(:current_user) { create(:user, :admin, organization: organization) }
    let(:organization) { budgets_group.organization }

    it_behaves_like "includes base workflow features"
    it_behaves_like "doesn't highlight any component"
    it_behaves_like "doesn't have orders"
    it_behaves_like "allows to vote in all components"

    context "when it has an order" do
      let(:order_component) { workflow.budgets.sample }
      let(:other_components) { workflow.budgets - [order_component] }
      let(:order) { create(:order, :with_projects, user: current_user, component: order_component) }

      before { order }

      shared_examples "allows voting in every components" do
        it "allows to vote in every component" do
          workflow.budgets.each do |component|
            expect(subject).to be_vote_allowed(component)
          end

          expect(workflow.allowed).to match_array(workflow.budgets)
        end

        it "has an allowed status for other components" do
          other_components.each do |component|
            expect(workflow.status(component)).to eq(:allowed)
          end
        end
      end

      it_behaves_like "doesn't highlight any component"
      it_behaves_like "has an in-progress order"
      it_behaves_like "allows voting in every components"

      it "has one discardable order" do
        expect(workflow.progress).to match_array([order_component])
      end

      context "when order has been checked out" do
        before { order.update! checked_out_at: Time.current }

        it_behaves_like "doesn't highlight any component"
        it_behaves_like "has a voted order"

        it "allows to vote in every component except the voted one" do
          expect(subject).not_to be_vote_allowed(order_component)

          other_components.each do |component|
            expect(subject).to be_vote_allowed(component)
          end

          expect(workflow.allowed).to match_array(other_components)
        end

        it "doesn't have any discardable order" do
          expect(workflow.discardable).to be_empty
        end
      end
    end
  end
end
