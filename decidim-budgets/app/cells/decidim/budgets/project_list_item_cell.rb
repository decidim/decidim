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

      delegate :current_user, :current_settings, :current_order, :current_component, :current_participatory_space, to: :parent_controller

      def project_image
        render
      end

      def project_text
        render
      end

      def project_data
        render
      end

      def project_data_number
        render
      end

      def project_data_votes
        render
      end

      def project_data_vote_button
        render
      end

      private

      def resource_path
        resource_locator(model).path
      end

      def resource_title
        translated_attribute model.title
      end

      def resource_added?
        current_order && current_order.projects.include?(model)
      end

      def data_class
        return "budget-list__data--added" if resource_added?
      end

      def vote_button_disabled?
        !current_settings.votes_enabled? || current_order_checked_out? || !current_participatory_space.can_participate?(current_user)
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
        return t("decidim.budgets.projects.project.remove") if resource_added?

        t("decidim.budgets.projects.project.add")
      end
    end
  end
end
