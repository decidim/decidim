# frozen_string_literal: true

module Decidim
  module Budgets
    # Exposes the order resource so users can checkout it.
    class OrdersController < Decidim::Budgets::ApplicationController
      include NeedsCurrentOrder

      def checkout
        enforce_permission_to :vote, :project, order: current_order, budget: budget, workflow: current_workflow

        Checkout.call(current_order) do
          on(:ok) do
            flash[:notice] = I18n.t("orders.checkout.success", scope: "decidim")
            redirect_to budget_path(budget)
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("orders.checkout.error", scope: "decidim")
            redirect_to budget_path(budget)
          end
        end
      end

      def destroy
        CancelOrder.call(current_order) do
          on(:ok) do
            flash[:notice] = I18n.t("orders.destroy.success", scope: "decidim")
            redirect_to budget_path(budget)
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("orders.destroy.error", scope: "decidim")
            redirect_to budget_path(budget)
          end
        end
      end

      private

      def budget
        @budget ||= Budget.find_by(id: params[:budget_id])
      end
    end
  end
end
