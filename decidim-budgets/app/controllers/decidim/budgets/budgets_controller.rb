# frozen_string_literal: true

module Decidim
  module Budgets
    # Exposes the budget resources so users can participate on them
    class BudgetsController < Decidim::Budgets::ApplicationController
      helper_method :announcement_body

      include Decidim::Budgets::Orderable
      include Decidim::TranslatableAttributes

      def index; end

      def show
        raise ActionController::RoutingError, "Not Found" unless budget

        redirect_to budget_projects_path(budget)
      end

      private

      def announcement_body
        @announcement_body ||= [translated_attribute(current_settings.announcement), translated_attribute(component_settings.announcement)].find(&:present?)&.html_safe
      end

      def budget
        @budget ||= Budget.where(component: current_component).includes(:projects).find_by(id: params[:id])
      end
    end
  end
end
