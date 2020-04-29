# frozen_string_literal: true

module Decidim
  module Budgets
    # Exposes the line items resource so users can create and remove from orders.
    class LineItemsController < Decidim::Budgets::ApplicationController
      include NeedsCurrentOrder

      helper_method :project

      def create
        enforce_permission_to :vote, :project, project: project

        respond_to do |format|
          AddLineItem.call(current_order, project, current_user) do
            on(:ok) do |order|
              self.current_order = order
              format.html { redirect_to :back }
              format.js { render "update_budget" }
            end

            on(:invalid) do
              render nothing: true, status: :unprocessable_entity
            end
          end
        end
      end

      def destroy
        respond_to do |format|
          RemoveLineItem.call(current_order, project) do
            on(:ok) do |_order|
              format.html { redirect_to :back }
              format.js { render "update_budget" }
            end

            on(:invalid) do
              render nothing: true, status: :unprocessable_entity
            end
          end
        end
      end

      private

      def project
        @project ||= Project.find_by(id: params[:project_id], component: current_component)
      end
    end
  end
end
