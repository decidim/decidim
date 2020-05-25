# frozen_string_literal: true

require "spec_helper"

module Decidim::Budgets::Groups
  describe Workflows::One do
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

      it "allows to vote in the order component" do
        expect(subject).to be_vote_allowed(order_component)
        expect(workflow.allowed).to match_array([order_component])
      end

      it "doesn't allow to vote in the other components" do
        other_components.each do |component|
          expect(subject).not_to be_vote_allowed(component)
        end
      end

      it "has a not_allowed status for other components" do
        other_components.each do |component|
          expect(workflow.status(component)).to eq(:not_allowed)
        end
      end

      it "would allow to vote in other components" do
        workflow.budgets.each do |component|
          expect(subject).to be_vote_allowed(component, false)
        end
      end

      it_behaves_like "doesn't highlight any component"
      it_behaves_like "has an in-progress order"
      it_behaves_like "allow to discard all the progress orders"

      context "when order has been checked out" do
        before { order.update! checked_out_at: Time.current }

        it_behaves_like "doesn't highlight any component"
        it_behaves_like "has a voted order"
        it_behaves_like "doesn't allow to vote in any component"

        it "has a not_allowed status for other components" do
          other_components.each do |component|
            expect(workflow.status(component)).to eq(:not_allowed)
          end
        end

        it "doesn't have any discardable order" do
          expect(workflow.discardable).to be_empty
        end
      end
    end
  end
end
