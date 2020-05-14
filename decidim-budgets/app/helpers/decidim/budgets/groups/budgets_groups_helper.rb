# frozen_string_literal: true

module Decidim
  module Budgets
    module Groups
      # A helper to render budgets groups
      module BudgetsGroupsHelper
        def budgets_link_list(budgets)
          budgets.map { |budget| link_to(translated_attribute(budget.name), main_component_path(budget)) }
                 .to_sentence
                 .html_safe
        end
      end
    end
  end
end
