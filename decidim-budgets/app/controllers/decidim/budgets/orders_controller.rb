# frozen_string_literal: true

module Decidim
  module Budgets
    # Exposes the order resource so users can checkout it.
    class OrdersController < Decidim::Budgets::ApplicationController
      include NeedsCurrentOrder

      def checkout
        enforce_permission_to :vote, :project, order: current_order, budget:, workflow: current_workflow

        Checkout.call(current_order) do
          on(:ok) do
            i18n_key = pending_to_vote_budgets.any? ? "success_html" : "success_no_left_budgets_html"
            flash[:notice] = I18n.t(i18n_key, scope: "decidim.orders.checkout", rest_of_budgets_link: "#budgets")
            redirect_to budgets_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("orders.checkout.error", scope: "decidim")
            redirect_to budgets_path
          end
        end
      end

      def destroy
        CancelOrder.call(current_order) do
          on(:ok) do
            flash[:notice] = I18n.t("orders.destroy.success", scope: "decidim")
            redirect_to redirect_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("orders.destroy.error", scope: "decidim")
            redirect_to redirect_path
          end
        end
      end

      private

      def budget
        @budget ||= Budget.find_by(id: params[:budget_id], component: current_component)
      end

      def redirect_path
        if params[:return_to] == "budget"
          budget_path(budget)
        else
          budgets_path
        end
      end

      def pending_to_vote_budgets
        current_workflow.budgets - current_workflow.voted - [current_order.budget]
      end
    end
  end
end
