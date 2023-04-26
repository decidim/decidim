# frozen_string_literal: true

module Decidim
  module Budgets
    # This cell renders an authorized_action button
    # to vote a given instance of a Project in a budget list
    class ProjectVoteButtonCell < Decidim::ViewModel
      include Decidim::ActionAuthorizationHelper
      include Decidim::Budgets::ProjectsHelper
      include Decidim::Budgets::Engine.routes.url_helpers

      delegate :current_user, :current_order, :current_component, :can_have_order?, to: :parent_controller

      private

      def project_item?
        options[:project_item]
      end

      def resource_path
        resource_locator([model.budget, model]).path
      end

      def resource_title
        translated_attribute model.title
      end

      def resource_added?
        current_order && current_order.projects.include?(model)
      end

      def resource_allocation
        current_order.allocation_for(model)
      end

      def modal_params
        return {} if resource_added? || below_maximum?

        { dialog_open: "" }
      end

      def remaining_amount
        model.budget.total_budget - (current_order&.total_budget || 0)
      end

      def below_maximum?
        model.budget_amount <= remaining_amount
      end

      def vote_button_disabled?
        current_user && !can_have_order?
      end

      def vote_button_class
        return "success" if resource_added?

        "hollow"
      end

      def vote_button_method
        return :delete if resource_added?

        :post
      end

      def vote_button_label
        if resource_added?
          return t(
            "decidim.budgets.projects.project.remove",
            resource_name: resource_title
          )
        end

        t("decidim.budgets.projects.project.add", resource_name: resource_title)
      end
    end
  end
end
