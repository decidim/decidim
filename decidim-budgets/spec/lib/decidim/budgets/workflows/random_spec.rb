# frozen_string_literal: true

require "spec_helper"

module Decidim::Budgets
  describe Workflows::Random do
    # !todo: fix pending xit
    subject(:workflow) { described_class.new(budgets_component, current_user) }

    let!(:budgets) { create_list(:budget, 6, component: budgets_component) }
    let(:budgets_component) { create(:budgets_component) }
    let(:current_user) { create(:user, :admin, organization: organization) }
    let(:organization) { budgets_component.organization }

    let(:chosen_resource) { workflow.send(:random_resource) }
    let(:not_chosen_resources) { workflow.budgets - [chosen_resource] }

    # xit_behaves_like "includes base workflow features"
    it_behaves_like "doesn't have orders"
    # xit_behaves_like "highlights a resource" do
    #   let(:highlighted_resource) { chosen_resource }
    # end

    xit "allows to vote only in the chosen resource" do
      expect(subject).to be_vote_allowed(chosen_resource)

      not_chosen_resources.each do |resource|
        expect(subject).not_to be_vote_allowed(resource)
      end

      expect(workflow.allowed).to match_array([chosen_resource])
    end

    xit "has an allowed status only for the chosen resource" do
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
        xit "allows to vote in the order resource" do
          expect(subject).to be_vote_allowed(order_resource)
          expect(workflow.allowed).to match_array([order_resource])
        end

        xit "doesn't allow to vote in the other resources" do
          other_resources.each do |resource|
            expect(subject).not_to be_vote_allowed(resource)
          end
        end

        xit "has a not_allowed status for other resources" do
          other_resources.each do |resource|
            expect(workflow.status(resource)).to eq(:not_allowed)
          end
        end
      end

      # xit_behaves_like "highlights a resource" do
      #   let(:highlighted_resource) { chosen_resource }
      # end
      # xit_behaves_like "has an in-progress order"
      # xit_behaves_like "allows to vote only in the order resource"
      # xit_behaves_like "allow to discard all the progress orders"

      xit "would not allow to vote in other resources" do
        other_resources.each do |resource|
          expect(subject).not_to be_vote_allowed(resource, false)
        end
      end

      context "when the order is not from the chosen resource" do
        let(:order_resource) { not_chosen_resources.first }

        # xit_behaves_like "highlights a resource" do
        #   let(:highlighted_resource) { order_resource }
        # end
        # xit_behaves_like "has an in-progress order"
        # xit_behaves_like "allows to vote only in the order resource"
        # xit_behaves_like "allow to discard all the progress orders"

        xit "would allow to vote in the chosen resource" do
          expect(subject).to be_vote_allowed(chosen_resource, false)
        end
      end

      context "when order has been checked out" do
        before { order.update! checked_out_at: Time.current }

        # xit_behaves_like "doesn't highlight any resource"
        # xit_behaves_like "has a voted order"
        # xit_behaves_like "doesn't allow to vote in any resource"

        xit "doesn't have any discardable order" do
          expect(workflow.discardable).to be_empty
        end
      end
    end
  end
end
