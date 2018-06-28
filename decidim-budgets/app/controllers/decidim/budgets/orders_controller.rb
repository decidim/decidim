# frozen_string_literal: true

module Decidim
  module Budgets
    # Exposes the order resource so users can checkout it.
    class OrdersController < Decidim::Budgets::ApplicationController
      include NeedsCurrentOrder

      def checkout
        enforce_permission_to :vote, :project, order: current_order

        Checkout.call(current_order, current_component) do
          on(:ok) do
            flash[:notice] = I18n.t("orders.checkout.success", scope: "decidim")
            redirect_to projects_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("orders.checkout.error", scope: "decidim")
            redirect_to projects_path
          end
        end
      end

      def destroy
        CancelOrder.call(current_order) do
          on(:ok) do
            flash[:notice] = I18n.t("orders.destroy.success", scope: "decidim")
            redirect_to projects_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("orders.destroy.error", scope: "decidim")
            redirect_to projects_path
          end
        end
      end
    end
  end
end
