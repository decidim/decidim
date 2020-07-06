# frozen_string_literal: true

module Decidim
  module Budgets
    # Exposes the budget resources so users can participate on them
    class BudgetsController < Decidim::Budgets::ApplicationController
      def index
        redirect_to budget_projects_path(current_workflow.single) if current_workflow.single?
      end

      def show
        redirect_to budget_projects_path(budget)
      end

      private

      def budget
        @budget ||= Budget.where(component: current_component).includes(:projects).find_by(id: params[:id])
      end
    end
  end
end
