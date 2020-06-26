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

      def limit_reached?
        current_user && current_workflow.limit_reached?
      end
    end
  end
end
