# frozen_string_literal: true

module Decidim
  module Budgets
    # This cell renders an authorized_action button
    # to vote a given instance of a Project in a budget list
    class ProjectVoteButtonCell < Decidim::ViewModel
      include Decidim::Budgets::ProjectsHelper
      include Decidim::Budgets::Engine.routes.url_helpers

      delegate :current_user, :current_order, :current_component, :can_have_order?, to: :parent_controller

      private

      def project_item?
        options[:project_item]
      end

      def button_extra_classes
        options[:button_extra_classes] || []
      end

      def resource_path
        resource_locator([model.budget, model]).path
      end

      def resource_index_path
        resource_locator(model.budget).path
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

      def vote_button_disabled?
        current_user && !can_have_order?
      end

      def vote_button_classes
        classes = []

        classes << if resource_added?
                     "success button__secondary budget-list__data--added"
                   else
                     "hollow button__transparent-secondary"
                   end

        classes << if project_item?
                     "button__lg"
                   else
                     "button__sm"
                   end

        classes << "budget-list__action" unless vote_button_disabled?
        classes << button_extra_classes

        classes.join(" ")
      end

      def vote_button_method
        return :delete if resource_added?

        :post
      end

      def authorization_redirect_path
        budget_focus_projects_path(budget, start_voting: true)
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
