# frozen_string_literal: true

module Decidim
  module Budgets
    # Exposes the order resource so users can checkout it.
    class OrdersController < Decidim::Budgets::ApplicationController
      include NeedsCurrentOrder

      helper_method :pending_to_vote_budgets

      def checkout
        enforce_permission_to :vote, :project, order: current_order, budget:, workflow: current_workflow

        Checkout.call(current_order) do
          on(:ok) do
            redirect_to status_budget_focus_order_path(budget)
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

      def status
        redirect_to redirect_path unless current_order.persisted?
      end

      def export_pdf
        enforce_permission_to :export_pdf, :order, order: current_order

        pdf_export = Decidim::Budgets::OrderPDF.new(current_order).render

        output = if pdf_signature_service
                   pdf_signature_service.new(pdf: pdf_export.read).signed_pdf
                 else
                   pdf_export.read
                 end

        send_data output, filename: "order_#{current_order.id}.pdf", type: "application/pdf"
      end

      private

      def budget
        @budget ||= Budget.find_by(id: params[:budget_id], component: current_component)
      end

      def pdf_signature_service
        @pdf_signature_service ||= Decidim.pdf_signature_service.to_s.safe_constantize
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
