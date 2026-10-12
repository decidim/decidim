# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Budgets
    describe OrdersController do
      let(:organization) { create(:organization) }
      let(:participatory_space) { create(:participatory_process, organization:) }
      let(:component) { create(:budgets_component, participatory_space:) }
      let(:budget) { create(:budget, component:) }
      let(:project) { create(:project, budget:, budget_amount: 80_000_000) }
      let(:user) { create(:user, :confirmed, organization:) }
      let!(:order) do
        order = create(:order, user:, budget:)
        order.projects << project
        order.checked_out_at = Time.current
        order.save!
        order
      end

      before do
        request.env["decidim.current_organization"] = organization
        request.env["decidim.current_participatory_space"] = participatory_space
        request.env["decidim.current_component"] = component
      end

      describe "DELETE destroy" do
        context "when the user is not signed in" do
          it "is not allowed" do
            delete :destroy, params: { budget_id: budget.id }
            expect(response).to have_http_status(:found)
          end
        end

        context "when the user is signed in" do
          before do
            sign_in user
            allow(controller).to receive(:budgets_path).and_return("/")
          end

          it "cancels the order" do
            expect do
              delete :destroy, params: { budget_id: budget.id }
            end.to change(Order, :count).by(-1)
          end
        end
      end
    end
  end
end
