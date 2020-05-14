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

      delegate :current_user, :current_settings, :current_order, :current_component, :current_participatory_space,
               :can_have_order?, to: :parent_controller

      def project_image
        render
      end

      def project_text
        render
      end

      def project_text_votes
        render view: :project_votes,
               locals: {
                 container_class: "budget-list__data__number budget-list__number hide-for-medium",
                 count_class: "display-inline",
                 you_voted_class: "display-inline text-sm ml-xs text-success text-uppercase"
               }
      end

      def project_text_number
        render view: :project_number, locals: { container_class: "budget-list__data__number budget-list__number hide-for-medium" }
      end

      def project_data
        render
      end

      def project_data_voted
        render
      end

      def project_data_votes
        render view: :project_votes,
               locals: {
                 container_class: "budget-list__data__votes",
                 count_class: "text-large",
                 you_voted_class: "text-sm mt-s text-success"
               }
      end

      def project_data_number
        render view: :project_number, locals: { container_class: "budget-list__data__number budget-list__number show-for-medium" }
      end

      def project_data_vote_button
        render
      end

      def voting_finished?
        !current_settings.votes_enabled? && current_settings.show_votes?
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
        return t("decidim.budgets.projects.project.remove") if resource_added?

        t("decidim.budgets.projects.project.add")
      end
    end
  end
end
