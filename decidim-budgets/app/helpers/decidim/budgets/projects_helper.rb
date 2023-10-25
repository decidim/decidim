# frozen_string_literal: true

module Decidim
  module Budgets
    # A helper to render order and budgets actions
    module ProjectsHelper
      include Decidim::ApplicationHelper
      include Decidim::MapHelper

      # Render a budget as a currency
      #
      # budget - A integer to represent a budget
      def budget_to_currency(budget)
        number_to_currency budget, unit: Decidim.currency_unit, precision: 0
      end

      # Return a percentage of the current order budget from the total budget
      def current_order_budget_percent
        current_order&.budget_percent.to_f.floor
      end

      # Return the minimum percentage of the current order budget from the total budget
      def current_order_budget_percent_minimum
        return 0 if current_order.minimum_projects_rule?

        if current_order.projects_rule?
          (current_order.minimum_projects.to_f / current_order.maximum_projects)
        else
          component_settings.vote_threshold_percent
        end
      end

      def budget_confirm_disabled_attr
        return if current_order_can_be_checked_out?

        %( disabled="disabled" ).html_safe
      end

      # Return true if the current order is checked out
      delegate :checked_out?, to: :current_order, prefix: true, allow_nil: true

      # Return true if the user can continue to the checkout process
      def current_order_can_be_checked_out?
        current_order&.can_checkout?
      end

      # Returns false if the current order does not have a rule for minimum budget
      # Returns false if the current order has not reached the minimum budget
      # Otherwhise returns true
      def current_order_minimum_reached?
        return false if current_order.minimum_budget.zero?

        current_order.total > current_order.minimum_budget
      end

      def current_rule_call_for_action_text
        return "" unless current_order

        if current_order_minimum_reached?
          t("minimum_reached", scope: "decidim.budgets.projects.order_progress.dynamic_help")
        elsif current_order.projects.empty?
          t("start_adding_projects", scope: "decidim.budgets.projects.order_progress.dynamic_help")
        else
          t("keep_adding_projects", scope: "decidim.budgets.projects.order_progress.dynamic_help")
        end
      end

      def current_rule_description
        return unless current_order

        rule_text = if current_order_minimum_reached?
                      ""
                    elsif current_order.projects_rule?
                      if current_order.minimum_projects.positive? && current_order.minimum_projects < current_order.maximum_projects
                        t(
                          "projects_rule.description",
                          scope: "decidim.budgets.projects.order_progress",
                          minimum_number: current_order.minimum_projects,
                          maximum_number: current_order.maximum_projects
                        )
                      else
                        t(
                          "projects_rule_maximum_only.description",
                          scope: "decidim.budgets.projects.order_progress",
                          maximum_number: current_order.maximum_projects
                        )
                      end
                    elsif current_order.minimum_projects_rule?
                      t(
                        "minimum_projects_rule.description",
                        scope: "decidim.budgets.projects.order_progress",
                        minimum_number: current_order.minimum_projects
                      )
                    else
                      t(
                        "vote_threshold_percent_rule.description",
                        scope: "decidim.budgets.projects.order_progress",
                        minimum_budget: budget_to_currency(current_order.minimum_budget)
                      )
                    end
        %(<strong>#{current_rule_call_for_action_text}</strong>. #{rule_text}).html_safe
      end

      # Serialize a collection of geocoded projects to be used by the dynamic map component
      #
      # geocoded_projects - A collection of geocoded projects
      def projects_data_for_map(geocoded_projects)
        geocoded_projects.map do |project|
          project_data_for_map(project)
        end
      end

      def project_data_for_map(project)
        project
          .slice(:latitude, :longitude, :address)
          .merge(
            title: decidim_html_escape(translated_attribute(project.title)),
            link: ::Decidim::ResourceLocatorPresenter.new([project.budget, project]).path,
            items: cell("decidim/budgets/project_metadata", project).send(:project_items_for_map).to_json
          )
      end

      def has_position?(project)
        return if project.address.blank?

        project.latitude.present? && project.longitude.present?
      end

      def filter_addition_type_values(added_count:)
        [
          ["all", { text: t("all", scope: "decidim.budgets.projects.project_filter"), count: nil }],
          ["added", { text: t("added", scope: "decidim.budgets.projects.project_filter"), count: added_count }]
        ]
      end

      def filter_sections
        @filter_sections ||= begin
          items = []
          items.append(method: :with_any_status, collection: filter_status_values, label_scope: "decidim.budgets.projects.filters", id: "status") if voting_finished?
          if current_component.has_subscopes?
            items.append(method: :with_any_scope, collection: resource_filter_scope_values(budget.scope), label_scope: "decidim.budgets.projects.filters", id: "scope")
          end
          if current_participatory_space.categories.any?
            items.append(method: :with_any_category, collection: filter_categories_values, label_scope: "decidim.budgets.projects.filters", id: "category")
          end
        end

        items.reject { |item| item[:collection].blank? }
      end

      def budgets_select_tag(name, options: {})
        select_tag(
          name,
          options_for_select(reference_budgets_for_select),
          options.merge(include_blank: I18n.t("decidim.budgets.prompt"))
        )
      end

      def reference_budgets_for_select
        references = Budget.where(component: current_component).order(weight: :asc)
        references.map do |budget|
          ["#{"&nbsp;" * 4} #{translated_attribute(budget.title)}".html_safe, budget.id]
        end
      end
    end
  end
end
