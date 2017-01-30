# frozen_string_literal: true

module Decidim
  module Budgets
    # Exposes the line items resource so users can create and remove from orders.
    class LineItemsController < Decidim::Budgets::ApplicationController
      include NeedsCurrentOrder

      def create
        current_order.projects << project
        save_current_order!
      end

      def destroy
        current_order.projects.destroy(project)
        save_current_order!
      end

      private

      def project
        @project ||= Project.where(id: params[:project_id], feature: current_feature).first
      end

      def save_current_order!
        if current_order.save
          render 'update_budget'
        else
          render nothing: true, status: 422
        end
      end
    end
  end
end
