# frozen_string_literal: true

module Decidim
  module Budgets
    # Exposes the line items resource so users can create and remove from orders.
    class LineItemsController < Decidim::Budgets::ApplicationController
      include NeedsCurrentOrder

      helper_method :project

      def create
        authorize_action! "vote"

        AddLineItem.call(current_order, project, current_user) do
          on(:ok) do |order|
            self.current_order = order
            render "update_budget"
          end

          on(:invalid) do
            render nothing: true, status: 422
          end
        end
      end

      def destroy
        RemoveLineItem.call(current_order, project) do
          on(:ok) do |_order|
            render "update_budget"
          end

          on(:invalid) do
            render nothing: true, status: 422
          end
        end
      end

      private

      def project
        @project ||= Project.where(id: params[:project_id], feature: current_feature).first
      end
    end
  end
end
