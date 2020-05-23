# frozen_string_literal: true

require "spec_helper"

module Decidim::Budgets::Groups
  describe Workflows::Random do
    subject(:workflow) { described_class.new(budgets_group, current_user) }

    let(:budgets_group) { create(:budgets_group_component, :with_children) }
    let(:current_user) { create(:user, :admin, organization: organization) }
    let(:organization) { budgets_group.organization }

    let(:chosen_component) { workflow.send(:random_component) }
    let(:not_chosen_components) { workflow.budgets - [chosen_component] }

    it_behaves_like "includes base workflow features"
    it_behaves_like "doesn't have orders"
    it_behaves_like "highlights a component" do
      let(:highlighted_component) { chosen_component }
    end

    it "allows to vote only in the chosen component" do
      expect(subject).to be_vote_allowed(chosen_component)

      not_chosen_components.each do |component|
        expect(subject).not_to be_vote_allowed(component)
      end

      expect(workflow.allowed).to match_array([chosen_component])
    end

    it "has an allowed status only for the chosen component" do
      expect(workflow.status(chosen_component)).to eq(:allowed)

      not_chosen_components.each do |component|
        expect(workflow.status(component)).to eq(:not_allowed)
      end
    end

    context "when it has an order" do
      let(:order_component) { chosen_component }
      let(:other_components) { workflow.budgets - [order_component] }
      let(:order) { create(:order, :with_projects, user: current_user, component: order_component) }

      before { order }

      shared_examples "allows to vote only in the order component" do
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
      end

      it_behaves_like "highlights a component" do
        let(:highlighted_component) { chosen_component }
      end
      it_behaves_like "has an in-progress order"
      it_behaves_like "allows to vote only in the order component"
      it_behaves_like "allow to discard all the progress orders"

      it "would not allow to vote in other components" do
        other_components.each do |component|
          expect(subject).not_to be_vote_allowed(component, false)
        end
      end

      context "when the order is not from the chosen component" do
        let(:order_component) { not_chosen_components.first }

        it_behaves_like "highlights a component" do
          let(:highlighted_component) { order_component }
        end
        it_behaves_like "has an in-progress order"
        it_behaves_like "allows to vote only in the order component"
        it_behaves_like "allow to discard all the progress orders"

        it "would allow to vote in the chosen component" do
          expect(subject).to be_vote_allowed(chosen_component, false)
        end
      end

      context "when order has been checked out" do
        before { order.update! checked_out_at: Time.current }

        it_behaves_like "doesn't highlight any component"
        it_behaves_like "has a voted order"
        it_behaves_like "doesn't allow to vote in any component"

        it "doesn't have any discardable order" do
          expect(workflow.discardable).to be_empty
        end
      end
    end
  end
end
