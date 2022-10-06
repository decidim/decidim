# frozen_string_literal: true

require "spec_helper"

describe BudgetsWorkflowRandom do
  subject(:workflow) { described_class.new(budgets_component, current_user) }

  let!(:budgets) { create_list(:budget, 6, component: budgets_component) }
  let(:budgets_component) { create(:budgets_component) }
  let(:current_user) { create(:user, :admin, organization:) }
  let(:organization) { budgets_component.organization }

  let(:chosen_resource) { workflow.send(:random_resource) }
  let(:not_chosen_resources) { workflow.budgets - [chosen_resource] }

  it_behaves_like "includes base workflow features"
  it_behaves_like "doesn't have orders"
  it_behaves_like "highlights a resource" do
    let(:highlighted_resource) { chosen_resource }
  end

  it "allows to vote only in the chosen resource" do
    expect(subject).to be_vote_allowed(chosen_resource)

    not_chosen_resources.each do |resource|
      expect(subject).not_to be_vote_allowed(resource)
    end

    expect(workflow.allowed).to match_array([chosen_resource])
  end

  it "has an allowed status only for the chosen resource" do
    expect(workflow.status(chosen_resource)).to eq(:allowed)

    not_chosen_resources.each do |resource|
      expect(workflow.status(resource)).to eq(:not_allowed)
    end
  end

  context "when it has an order" do
    let(:order_resource) { chosen_resource }
    let(:other_resources) { workflow.budgets - [order_resource] }
    let(:order) { create(:order, :with_projects, user: current_user, budget: order_resource) }

    before { order }

    shared_examples "allows to vote only in the order resource" do
      it "allows to vote in the order resource" do
        expect(subject).to be_vote_allowed(order_resource)
        expect(workflow.allowed).to match_array([order_resource])
      end

      it "doesn't allow to vote in the other resources" do
        other_resources.each do |resource|
          expect(subject).not_to be_vote_allowed(resource)
        end
      end

      it "has a not_allowed status for other resources" do
        other_resources.each do |resource|
          expect(workflow.status(resource)).to eq(:not_allowed)
        end
      end
    end

    it_behaves_like "highlights a resource" do
      let(:highlighted_resource) { chosen_resource }
    end
    it_behaves_like "has an in-progress order"
    it_behaves_like "allows to vote only in the order resource"

    it "doesn't allow to discard the highlighted resource" do
      expect(workflow.discardable).to be_empty
    end

    it "would not allow to vote in other resources" do
      other_resources.each do |resource|
        expect(subject).not_to be_vote_allowed(resource, consider_progress: false)
      end
    end

    context "when the order is not from the chosen resource" do
      let(:order_resource) { not_chosen_resources.first }

      it_behaves_like "highlights a resource" do
        let(:highlighted_resource) { order_resource }
      end
      it_behaves_like "has an in-progress order"
      it_behaves_like "allows to vote only in the order resource"

      it "would allow to vote in the chosen resource" do
        expect(subject).to be_vote_allowed(chosen_resource, consider_progress: false)
      end
    end

    context "when order has been checked out" do
      before { order.update! checked_out_at: Time.current }

      it_behaves_like "doesn't highlight any resource"
      it_behaves_like "has a voted order"
      it_behaves_like "doesn't allow to vote in any resource"

      it "doesn't have any discardable order" do
        expect(workflow.discardable).to be_empty
      end
    end
  end
end
