# frozen_string_literal: true

module Decidim
  module Budgets
    # Exposes the line items resource so users can create and remove from orders.
    class LineItemsController < Decidim::Budgets::ApplicationController
      include NeedsCurrentOrder

      helper_method :project

      def create
        order.projects << project
        save_order!
      end

      def destroy
        order.projects.destroy(project)
        save_order!
      end

      private

      def project
        @project ||= Project.where(id: params[:project_id], feature: current_feature).first
      end

      def order
        @order ||= (current_order || Order.create(user: current_user, feature: current_feature))
      end

      def save_order!
        if order.save
          self.current_order = order
          render 'update_budget'
        else
          render nothing: true, status: 422
        end
      end
    end
  end
end
