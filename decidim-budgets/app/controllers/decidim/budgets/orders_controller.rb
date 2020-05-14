# frozen_string_literal: true

module Decidim
  module Budgets
    # Exposes the order resource so users can checkout it.
    class OrdersController < Decidim::Budgets::ApplicationController
      include NeedsCurrentOrder
      include Decidim::ComponentPathHelper

      def checkout
        enforce_permission_to :vote, :project, order: current_order, parent_component_context: parent_component_context

        Checkout.call(current_order, current_component) do
          on(:ok) do
            flash[:notice] = I18n.t("orders.checkout.success", scope: "decidim")
            redirect_to return_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("orders.checkout.error", scope: "decidim")
            redirect_to return_path
          end
        end
      end

      def destroy
        CancelOrder.call(current_order) do
          on(:ok) do
            flash[:notice] = I18n.t("orders.destroy.success", scope: "decidim")
            redirect_to return_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("orders.destroy.error", scope: "decidim")
            redirect_to return_path
          end
        end
      end

      def return_path
        if params[:return_path]
          params[:return_path]
        else
          main_component_path(current_component.parent || current_component)
        end
      end
    end
  end
end
