# frozen_string_literal: true

module Decidim
  module Budgets
    # This cell renders the budget item list in the budgets list
    class BudgetListItemCell < BaseCell
      include Decidim::Budgets::ProjectsHelper

      delegate :highlighted, to: :current_workflow

      property :title, :description, :total_budget
      alias budget model

      private

      def card_class
        ["card--list__item"].tap do |list|
          unless voting_finished?
            list << "card--list__data-added" if voted?
            list << "card--list__data-progress" if progress?
          end
          list << "budget--highlighted" if highlighted?
        end.join(" ")
      end

      def link_class
        "card__link card--list__heading"
      end

      def voted?
        current_user && status == :voted
      end

      def progress?
        current_user && status == :progress
      end

      def highlighted?
        highlighted.include?(budget)
      end

      def status
        @status ||= current_workflow.status(budget)
      end

      # If the voting is open, then do the link for the authorized focus mode
      # If not (i.e. voting is disabled or finished), then link to the resource itself
      def link_to_resource_wrapper(css_class, &block)
        if voting_open?
          action_authorized_link_to "vote",
                                      budget_focus_projects_path(budget, start_voting: true),
                                      resource: budget,
                                      data: { "redirect-url": budget_focus_projects_path(budget) },
                                      class: css_class do
                                        yield
                                      end
        else
          link_to resource_locator(budget).path, class: css_class do
            yield
          end
        end
       end

      def button_class
        "hollow" if voted? || !highlighted?
      end

      def button_text
        key = if current_workflow.vote_allowed?(budget) && !voted?
                progress? ? :progress : :vote
              else
                :show
              end

        t(key, scope: i18n_scope)
      end

      def i18n_scope
        "decidim.budgets.budgets_list"
      end

      def current_workflow
        @current_workflow ||=
          controller.try(:current_workflow) ||
          Decidim::Budgets.workflows[component.settings.workflow.to_sym].new(component, current_user)
      end

      def component
        @component ||= controller.try(:current_component) || budget.component
      end

      def voting_context?
        controller.respond_to?(:voting_finished?)
      end

      def voting_finished?
        return unless voting_context?

        controller.voting_finished?
      end
    end
  end
end
