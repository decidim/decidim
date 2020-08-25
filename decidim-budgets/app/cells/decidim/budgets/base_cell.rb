# frozen_string_literal: true

module Decidim
  module Budgets
    # This cell has the commons for the budgets cells
    class BaseCell < Decidim::ViewModel
      include Decidim::LayoutHelper
      include Decidim::SanitizeHelper
      include Decidim::ComponentPathHelper
      include Decidim::Budgets::Engine.routes.url_helpers

      delegate :current_user, :current_settings, :current_component, :current_workflow, to: :controller
      delegate :settings, to: :current_component

      def budgets_link_list(budgets)
        budgets.map { |budget| link_to(translated_attribute(budget.title), resource_locator(budget).path) }
               .to_sentence
               .html_safe
      end
    end
  end
end
