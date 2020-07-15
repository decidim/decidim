# frozen_string_literal: true

module Decidim
  module Budgets
    # This cell renders a horizontal project card
    # for an given instance of a Project in a budget list
    class ProjectListItemCell < Decidim::ViewModel
      include ActiveSupport::NumberHelper
      include Decidim::LayoutHelper
      include Decidim::ActionAuthorizationHelper
      include Decidim::Budgets::ProjectsHelper
      include Decidim::Budgets::Engine.routes.url_helpers

      delegate :current_user, :current_settings, :current_order, :current_component, :current_participatory_space, :can_have_order?, to: :parent_controller

      def project_image
        render
      end

      def project_text
        render
      end

      def project_data
        render
      end

      def project_data_voted_check
        render
      end

      def project_data_final
        render
      end

      def project_data_numbers
        render
      end

      def project_data_vote_button
        render
      end

      def voting_finished?
        !current_settings.votes_enabled? && current_settings.show_votes?
      end

      private

      def resource_path
        resource_locator([model.budget, model]).path(filter_link_params)
      end

      def resource_title
        translated_attribute model.title
      end

      def resource_added?
        current_order && current_order.projects.include?(model)
      end

      def data_class
        [].tap do |list|
          list << "budget-list__data--added" if can_have_order? && resource_added?
          list << "show-for-medium" if voting_finished? || (current_order_checked_out? && !resource_added?)
        end.join(" ")
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
