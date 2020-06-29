# frozen_string_literal: true

module Decidim
  module Budgets
    # Exposes the budget resources so users can participate on them
    class BudgetsController < Decidim::Budgets::ApplicationController
      helper_method :current_workflow

      def index
        redirect_to budget_path(current_workflow.single) if current_workflow.single?
      end

      def current_workflow
        @current_workflow ||= Decidim::Budgets.workflows[workflow_name].new(current_component, current_user)
      end

      private

      def workflow_name
        @workflow_name ||= current_component.settings.workflow.to_sym
      end
    end
  end
end
