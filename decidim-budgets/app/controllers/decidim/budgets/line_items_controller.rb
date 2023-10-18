# frozen_string_literal: true

module Decidim
  module Budgets
    # Exposes the line items resource so users can create and remove from orders.
    class LineItemsController < Decidim::Budgets::ApplicationController
      include NeedsCurrentOrder

      helper_method :budget, :project

      def create
        enforce_permission_to :vote, :project, project:, budget:, workflow: current_workflow

        respond_to do |format|
          AddLineItem.call(persisted_current_order, project, current_user) do
            on(:ok) do |order|
              self.current_order = order
              format.html { redirect_back(fallback_location: budget_path(budget)) }
              format.js { render "update_budget" }
            end

            on(:invalid) do
              format.js { render "update_budget", status: :unprocessable_entity }
            end
          end
        end
      end

      def destroy
        respond_to do |format|
          RemoveLineItem.call(current_order, project) do
            on(:ok) do |_order|
              format.html { redirect_back(fallback_location: budget_path(budget)) }
              format.js { render "update_budget" }
            end

            on(:invalid) do
              format.js { render "update_budget", status: :unprocessable_entity }
            end
          end
        end
      end

      private

      def project
        @project ||= budget&.projects&.find_by(id: params[:project_id])
      end

      def budget
        @budget ||= Budget.find_by(id: params[:budget_id], component: current_component)
      end
    end
  end
end
