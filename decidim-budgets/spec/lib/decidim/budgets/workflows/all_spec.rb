# frozen_string_literal: true

require "spec_helper"

module Decidim::Budgets
  describe Workflows::All do
    # !todo: fix pending xit
    subject(:workflow) { described_class.new(budgets_component, current_user) }

    let!(:budgets) { create_list(:budget, 6, component: budgets_component) }
    let(:budgets_component) { create(:budgets_component) }
    let(:current_user) { create(:user, :admin, organization: organization) }
    let(:organization) { budgets_component.organization }

    # xit_behaves_like "includes base workflow features"
    it_behaves_like "doesn't highlight any resource"
    # xit_behaves_like "doesn't have orders"
    it_behaves_like "allows to vote in all resources"

    context "when it has an order" do
      let(:order_resource) { workflow.budgets.sample }
      let(:other_resources) { workflow.budgets - [order_resource] }
      let(:order) { create(:order, :with_projects, user: current_user, budget: order_resource) }

      before { order }

      shared_examples "allows voting in every resources" do
        xit "allows to vote in every resource" do
          workflow.budgets.each do |resource|
            expect(subject).to be_vote_allowed(resource)
          end

          expect(workflow.allowed).to match_array(workflow.budgets)
        end

        xit "has an allowed status for other resources" do
          other_resources.each do |resource|
            expect(workflow.status(resource)).to eq(:allowed)
          end
        end
      end

      # xit_behaves_like "doesn't highlight any resource"
      # xit_behaves_like "has an in-progress order"
      # xit_behaves_like "allows voting in every resources"

      xit "has one discardable order" do
        expect(workflow.progress).to match_array([order_resource])
      end

      context "when order has been checked out" do
        before { order.update! checked_out_at: Time.current }

        # xit_behaves_like "doesn't highlight any resource"
        # xit_behaves_like "has a voted order"

        xit "allows to vote in every resource except the voted one" do
          expect(subject).not_to be_vote_allowed(order_resource)

          other_resources.each do |resource|
            expect(subject).to be_vote_allowed(resource)
          end

          expect(workflow.allowed).to match_array(other_resources)
        end

        xit "doesn't have any discardable order" do
          expect(workflow.discardable).to be_empty
        end
      end
    end
  end
end
